require 'rails_helper'

RSpec.describe Sms::TwilioCommunicator do
  describe "#send_message" do
    subject { described_class.new(account_sid:, auth_token:, from_number:).send_message(phone_number:, message:) }

    let(:message) { "Hello, world!" }
    let(:account_sid) { "FAKE_SID" }
    let(:auth_token) { "FAKE_TOKEN" }
    let(:from_number) { "+15555555555" }

    let(:phone_number) { "1 234 567 8900" }

    it "calls the Twilio API" do
      expect(Twilio::REST::Client).to receive(:new).with(
        account_sid,
        auth_token
      ).and_call_original

      expect_any_instance_of(Twilio::REST::Client).to receive_message_chain(:messages, :create).with(
        body: "Hello, world!",
        from: "+15555555555",
        to: "+12345678900"
      )

      subject
    end
  end
end
