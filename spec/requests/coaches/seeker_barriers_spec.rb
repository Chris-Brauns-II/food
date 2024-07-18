require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Coaches::SeekerBarriersController", type: :request do
  path '/coaches/contexts/{id}/update_barriers' do
    put "update barriers" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :barriers_params, in: :body, schema: {
        type: :object,
        properties: {
          barriers: {
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: %w[barriers]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:id) { person_context.id }
      let(:barriers_params) do
        {
          barriers:
        }
      end
      let(:barriers) do
        [create(:barrier).barrier_id]
      end

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Update barriers' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:update_barriers)
              .with(person_id: id, barriers:, trace_id: be_a(String))
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
