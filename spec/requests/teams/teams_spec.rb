require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Teams", type: :request do
  path '/teams/teams' do
    get "get all teams" do
      tags 'Teams'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Returns all teams' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/team'
                 }

          before do
            create(:teams__team, name: "Team 1")
            create(:teams__team, name: "Team 2")
          end

          before do
            expect(Teams::TeamsQuery)
              .to receive(:all_teams)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
