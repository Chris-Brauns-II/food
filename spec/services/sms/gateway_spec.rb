require 'rails_helper'

RSpec.describe Sms::Gateway do
  describe ".build" do
    subject { described_class.build(strategy:) }

    context "when the strategy is real" do
      let(:strategy) { described_class::Strategies::TWILIO }

      it "returns a TwilioCommunicator" do
        expect(subject).to be_a(Sms::TwilioCommunicator)
      end
    end

    context "when the strategy is fake" do
      let(:strategy) { described_class::Strategies::FAKE }

      it "returns a FakeComunicator" do
        expect(subject).to be_a(Sms::FakeCommunicator)
      end
    end
  end
end
