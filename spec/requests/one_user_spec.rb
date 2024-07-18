require 'rails_helper'
require 'swagger_helper'

RSpec.describe "OneUsers", type: :request do
  path '/one_user' do
    get "The current user" do
      tags 'Seeker'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Retrieve user' do
          schema '$ref' => '#/components/schemas/one_user'

          context "bare bones" do
            run_test!
          end

          context "fully loaded" do
            before do
              seeker = create(:seeker, user_id: user.id)
              create(:onboarding_session, seeker:)
              create(:recruiter, user:)
              create(:training_provider_profile, user:)
            end

            run_test!
          end
        end
      end
    end
  end
end
