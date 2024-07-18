require 'rails_helper'

RSpec.describe AuthClient::Factory do
  subject do
    described_class.build(
      auth0_domain:,
      mock_auth:,
      mock_email:,
      mock_sub:
    )
  end

  let(:auth0_domain) { "some-domain.com" }
  let(:mock_email) { "cool@email.com" }
  let(:mock_sub) { "cool" }

  describe ".build" do
    context "when mock_auth is true" do
      let(:mock_auth) { "true" }

      it "creates a fake auth client" do
        expect(AuthClient::Fake)
          .to receive(:new)
          .with(
            email: mock_email,
            sub: mock_sub
          )
          .and_call_original

        expect(subject).to be_a(AuthClient::Fake)
      end
    end

    context "when mock_auth is false" do
      let(:mock_auth) { "false" }

      it "creates a auth0 client" do
        expect(AuthClient::Auth0Client)
          .to receive(:new)
          .with(
            auth0_domain:
          )
          .and_call_original

        expect(subject).to be_a(AuthClient::Auth0Client)
      end
    end
  end
end
