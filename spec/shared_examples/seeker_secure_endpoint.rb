RSpec.shared_context "profile owner" do
  include_context "authenticated"

  let(:seeker) { create(:seeker, user_id: user.id) }
end

RSpec.shared_context "profile owner openapi" do
  include_context "authenticated openapi"

  let(:seeker) { create(:seeker, user_id: user.id) }
end

RSpec.shared_examples "a seeker secured endpoint" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "authenticated" do
    context "user is a coach" do
      include_context "coach authenticated"

      it "returns 200" do
        subject

        expect(response).to have_http_status(:ok)
      end
    end

    context "user is not a coach" do
      include_context "authenticated"

      context "user is the profile owner" do
        include_context "profile owner"

        it "returns 200" do
          subject

          expect(response).to have_http_status(:ok)
        end
      end

      context "user is not the profile owner" do
        let(:seeker) { create(:seeker) }

        it "returns 401" do
          subject

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end

RSpec.shared_context "seeker authenticated openapi" do
  let!(:user) do
    User.find_or_create_by!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
  end
  let!(:seeker) { create(:seeker, user_id: user.id) }
  let(:Authorization) { "Bearer #{user.sub}" }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "seeker spec unauthenticated openapi" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
