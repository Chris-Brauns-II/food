require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Session", type: :request do
  path '/session' do
    post "Indicate a new session started" do
      tags 'Users'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '202', 'Session Started' do
          run_test!
        end
      end
    end
  end
end
