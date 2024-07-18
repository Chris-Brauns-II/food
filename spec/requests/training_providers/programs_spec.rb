require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Programs", type: :request do
  path '/training_providers/{id}/programs' do
    post 'Create a program' do
      tags 'Admin'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

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

      let(:id) { SecureRandom.uuid }
      let(:program_params) do
        {
          name: "name",
          description: "description",
          trainingProviderId: SecureRandom.uuid
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Creates a program' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                training_provider_id: id,
                schema: Commands::CreateTrainingProviderProgram::V1,
                data: {
                  program_id: be_a(String),
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
