require 'rails_helper'

RSpec.describe AuthClient::Fake do
  let(:instance) { described_class.new(email:, sub:) }
  let(:email) { "the@email.com" }
  let(:sub) { "cool sub" }

  describe "#validate_token" do
    subject { instance.validate_token(token) }

    let(:token) { "123" }

    it "returns a sub pass to the instance" do
      expect(subject).to be_success
      expect(subject.sub).to eq(token)
    end
  end

  describe "#get_user_info" do
    subject { instance.get_user_info(token) }

    let(:token) { "123" }

    it "returns a sub and email passed to the instance" do
      expect(subject).to eq(
        {
          'email' => email,
          'email_verified' => nil,
          'picture' => nil,
          'nickname' => nil,
          'sub' => sub
        }
      )
    end
  end
end
