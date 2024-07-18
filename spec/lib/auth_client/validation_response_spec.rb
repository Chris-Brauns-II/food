require 'rails_helper'

RSpec.describe AuthClient::ValidationResponse do
  let(:success) { described_class.ok(sub:) }
  let(:failure) { described_class.err(message:, status:) }

  let(:sub) { "cool sub" }
  let(:message) { "bummer" }
  let(:status) { "ded" }

  describe "#success?" do
    context "when the response is ok" do
      it "returns true" do
        expect(success).to be_success
      end
    end

    context "when the response is an error" do
      it "returns true" do
        expect(failure).not_to be_success
      end
    end
  end

  describe "#sub" do
    context "when the response is ok" do
      it "returns the sub" do
        expect(success.sub).to eq(sub)
      end
    end

    context "when the response is an error" do
      it "raises a ErrorResponseError" do
        expect { failure.sub }.to raise_error(described_class::ErrorResponseError)
      end
    end
  end

  describe "#message" do
    context "when the response is ok" do
      it "raises a SuccessResponseError" do
        expect { success.message }.to raise_error(described_class::SuccessResponseError)
      end
    end

    context "when the response is an error" do
      it "returns the message" do
        expect(failure.message).to eq(message)
      end
    end
  end

  describe "#status" do
    context "when the response is ok" do
      it "raises a SuccessResponseError" do
        expect { success.status }.to raise_error(described_class::SuccessResponseError)
      end
    end

    context "when the response is an error" do
      it "returns the status" do
        expect(failure.status).to eq(status)
      end
    end
  end
end
