require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Programs", type: :request do
  path '/programs/{id}' do
    get 'Get a program' do
      tags 'Admin'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      let(:program) { create(:program) }
      let(:id) { program.id }

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retrieves a program' do
          schema "$ref" => "#/components/schemas/program"

          run_test!
        end
      end
    end

    put 'Update ane existing program' do
      tags 'Admin'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :program_params, in: :body, schema: {
        type: :object,
        properties: {
          name: {
            type: :string
          },
          description: {
            type: :string
          },
          trainingProviderId: {
            type: :string,
            format: :uuid
          }
        },
        required: %w[name description trainingProviderId]
      }

      let(:program_params) do
        {
          name: "name",
          description: "description",
          trainingProviderId: SecureRandom.uuid
        }
      end
      let(:program) { create(:program) }
      let(:id) { program.id }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '202', 'Updates the program' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                training_provider_id: program_params[:trainingProviderId],
                schema: Commands::UpdateTrainingProviderProgram::V1,
                data: {
                  program_id: id,
                  name: "name",
                  description: "description"
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
