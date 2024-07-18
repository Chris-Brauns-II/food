require 'rails_helper'

RSpec.describe AuthClient::Auth0Client do
  let(:instance) { described_class.new(auth0_domain:) }
  let(:auth0_domain) { "some_domain.com" }
  let(:token) { "some token" }

  describe "#validate_token" do
    subject { instance.validate_token(token) }

    context "when the well knowns is succesfully retrieved" do
      before do
        allow(Net::HTTP)
          .to receive(:get_response)
          .and_return(response)

        expect(response).to receive(:body) { '{}' }
      end

      let(:response) { Net::HTTPSuccess.new(1.0, '200', '{}') }

      context "when the JWT successfully decodes" do
        before do
          allow(JWT)
            .to receive(:decode)
            .and_return([
                          {
                            "sub" => "sub|#{sub}"
                          }
                        ])
        end

        let(:sub) { "123abc" }

        it "returns validation response" do
          expect(subject).to be_success
          expect(subject.sub).to eq(sub)
        end
      end

      context "when the JWT doesn't successfully decode" do
        before do
          allow(JWT)
            .to receive(:decode)
            .and_raise(JWT::DecodeError)
        end

        it "returns a non successful validation response" do
          expect(subject).not_to be_success
        end
      end
    end

    context "when the well knowns are not successfuly" do
      before do
        allow(Net::HTTP)
          .to receive(:get_response)
          .and_return(Net::HTTPServerError.new(1.0, '500', '{}'))
      end

      it "returns a non successful validation response" do
        expect(subject).not_to be_success
      end
    end
  end

  describe "#get_user_info" do
    subject { instance.get_user_info(token) }

    let(:uri) { URI("https://#{auth0_domain}/userinfo") }
    let(:token) { "123" }
    let(:response) { Net::HTTPSuccess.new(1.0, '200', '{}') }

    before do
      expect(Net::HTTP)
        .to receive(:start)
        .with(
          uri.hostname,
          uri.port,
          use_ssl: true
        )
        .and_return(response)

      expect(response).to receive(:body) { '{"email": "abc@gmail.com"}' }
    end

    it "returns the json parsed response to the call to user info" do
      expect(subject).to eq(
        {
          'email' => "abc@gmail.com"
        }
      )
    end
  end
end
