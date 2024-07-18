require 'rails_helper'

RSpec.describe UserFinder do
  describe '.find_or_create' do
    subject do
      described_class.new.find_or_create(
        sub:,
        token:,
        auth_client:
      )
    end

    let(:auth_client) { AuthClient::Fake.new(email:, sub:) }
    let(:token) { "123" }
    let(:email) { "some@email.com" }
    let(:sub) { "sup" }

    context "when a user already exists for a provided sub" do
      let!(:user) { create(:user, sub:) }

      it "returns the existing user" do
        expect(subject).to eq(user)
      end
    end

    context "when a user doesn't exists for a provided sub" do
      before do
        allow(auth_client)
          .to receive(:get_user_info)
          .and_return(
            {
              'email' => email,
              'email_verified' => email_verified,
              'picture' => image
            }
          )
      end

      let(:email_verified) { Time.zone.parse('2000-1-1') }
      let(:image) { 'an image' }

      it "creates a user record and enqueues a create event job" do
        expect(subject).to be_a(User)
        expect(subject.email).to eq(email)
        expect(subject.email_verified).to eq(email_verified)
        expect(subject.image).to eq(image)
        expect(subject.sub).to eq(sub)
      end
    end
  end
end
