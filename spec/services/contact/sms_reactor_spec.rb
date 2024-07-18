require 'rails_helper'

RSpec.describe Contact::SmsReactor do
  it_behaves_like "a non replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new(sms_service:, message_service: MessageService.new).handle_message(message) }

    let(:sms_service) { instance_double(Sms::SmsCommunicator, send_message: nil) }
    let(:message) do
      build(
        :message,
        schema: Commands::SendSmsMessage::V3,
        data: {
          phone_number:,
          message: sms_message
        }
      )
    end

    let(:sms_message) { "Hello, world!" }
    let(:phone_number) { "1234567890" }

    it "calls the Sms Gateway" do
      expect(sms_service).to receive(:send_message).with(
        phone_number: "1234567890",
        message: "Hello, world!"
      )

      subject
    end

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::SmsMessageSent::V2,
        message_id: message.stream.message_id,
        trace_id: message.trace_id,
        data: {
          phone_number:,
          message: sms_message
        }
      ).and_call_original

      expect(Sentry).not_to receive(:capture_exception)

      subject
    end

    context "when the sms_service raises" do
      before do
        allow(sms_service).to receive(:send_message).and_raise(error)
      end

      let(:error) { StandardError.new }

      it "reports the error to sentry" do
        expect(Sentry).to receive(:capture_exception).with(error)

        subject
      end
    end
  end
end
