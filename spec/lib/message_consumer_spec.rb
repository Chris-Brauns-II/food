require 'rails_helper'

RSpec.describe MessageConsumer do
  describe ".on_message" do
    let(:sub_klass) do
      Class.new(described_class) do
        on_message Events::SessionStarted::V1, &:serialize
      end
    end

    let(:message) { build(:message, schema: Events::SessionStarted::V1, data: Core::Nothing) }

    it "executes the events for the approprate message" do
      expect(message)
        .to receive(:serialize)

      sub_klass.new.handle_message(message)
    end

    context "when the message causes an exception" do
      let(:sub_klass) do
        Class.new(described_class) do
          on_message Events::SessionStarted::V1 do |_|
            raise IndexError, "error"
          end
        end
      end

      it "captures the causing error in a wrapped exception" do
        expect(Sentry)
          .to receive(:capture_exception)
          .with(be_a(described_class::FailedToHandleMessage))

        expect { sub_klass.new.handle_message(message) }.to raise_error do |error|
          expect(error).to be_a(described_class::FailedToHandleMessage)
          expect(error.message).to eq("error")
          expect(error.erroring_message).to eq(message)
          expect(error.cause).to be_a(IndexError)
        end
      end
    end

    context "when on_message is subscribed to a deprecated message" do
      let(:sub_klass) do
        Class.new(described_class) do
          on_message Core::Schema.deprecated(data: Core::Nothing,
                                             metadata: Core::Nothing,
                                             stream: Streams::User,
                                             message_type: MessageTypes::TestingOnly::TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST,
                                             version: 1), &:checksum
        end

        it "prints an error to the console" do
          expect(Rails.logger)
            .to receive(:debug)
            .and_call_original

          sub_klass.new
        end
      end
    end

    context "when on_message is sync" do
      let(:sub_klass) do
        Class.new(described_class) do
          on_message Events::SessionStarted::V1, :sync, &:checksum
        end
      end

      it "correctly reports how it handles events" do
        consumer = sub_klass.new

        expect(consumer.all_handled_messages).to eq([Events::SessionStarted::V1])
        expect(consumer.handled_messages_sync).to eq([Events::SessionStarted::V1])
        expect(consumer.handled_messages).to eq([])
      end
    end

    context "when on_message is async" do
      let(:sub_klass) do
        Class.new(described_class) do
          on_message Events::SessionStarted::V1, &:checksum
        end
      end

      it "correctly reports how it handles events" do
        consumer = sub_klass.new

        expect(consumer.all_handled_messages).to eq([Events::SessionStarted::V1])
        expect(consumer.handled_messages_sync).to eq([])
        expect(consumer.handled_messages).to eq([Events::SessionStarted::V1])
      end
    end
  end

  describe "#flush" do
    subject { described_class.new.flush }

    it "implements an empty method" do
      expect(subject).to eq(nil)
    end
  end
end
