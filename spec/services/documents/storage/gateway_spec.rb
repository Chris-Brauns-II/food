require 'rails_helper'

RSpec.describe Documents::Storage::Gateway do
  describe ".build" do
    subject { described_class.build(strategy:) }

    context "when the strategy is real" do
      let(:strategy) { described_class::Strategies::REAL }

      it "returns a TwilioCommunicator" do
        expect(subject).to be_a(Documents::Storage::RealCommunicator)
      end
    end

    context "when the strategy is db only" do
      let(:strategy) { described_class::Strategies::DB_ONLY }

      it "returns a FakeComunicator" do
        expect(subject).to be_a(Documents::Storage::DbOnlyCommunicator)
      end
    end

    context "when the strategy not valid" do
      let(:strategy) { SecureRandom.uuid }

      it "returns a FakeComunicator" do
        expect { subject }.to raise_error(described_class::DocumentsStorageGatewayEnvvarNotSetError)
      end
    end
  end
end
