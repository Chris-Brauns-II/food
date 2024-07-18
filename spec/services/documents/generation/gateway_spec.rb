require 'rails_helper'

RSpec.describe Documents::Generation::Gateway do
  describe ".build" do
    subject { described_class.build(strategy:) }

    context "when the strategy is real" do
      let(:strategy) { described_class::Strategies::REAL }

      it "returns a TwilioCommunicator" do
        expect(subject).to be_a(Documents::Generation::RealCommunicator)
      end
    end

    context "when the strategy is fake" do
      let(:strategy) { described_class::Strategies::FAKE }

      it "returns a FakeComunicator" do
        expect(subject).to be_a(Documents::Generation::FakeCommunicator)
      end
    end

    context "when the strategy not valid" do
      let(:strategy) { SecureRandom.uuid }

      it "raises a DocumentsGenerationGatewayEnvvarNotSetError" do
        expect { subject }.to raise_error(described_class::DocumentsGenerationGatewayEnvvarNotSetError)
      end
    end
  end
end
