require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Coaches::Feeds", type: :request do
  path '/coaches/feeds' do
    get "retrieve all feeds" do
      tags 'Coaches'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '200', 'retrieve all seekers' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     contextId: { type: :string },
                     description: { type: :string },
                     occurredAt: { type: :string, format: :datetime },
                     seekerEmail: { type: :string, format: :email }
                   },
                   required: %w[id seekerEmail]
                 }

          context "" do
            before do
              create(:coaches__feed_event)
            end

            run_test!
          end
        end
      end
    end
  end
end
