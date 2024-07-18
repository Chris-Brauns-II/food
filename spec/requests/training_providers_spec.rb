require 'rails_helper'
require 'swagger_helper'

RSpec.describe "TrainingProvider", type: :request do
  path '/training_providers' do
    post 'Create a Training Provider' do
      tags 'Admin'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :training_provider_params, in: :body, schema: {
        type: :object,
        properties: {
          trainingProvider: {
            type: :object,
            properties: {
              name: {
                type: :string
              },
              description: {
                type: :string
              }
            },
            required: %w[name description]
          }
        },
        required: %w[training_provider]
      }

      let(:training_provider_params) do
        {
          trainingProvider: {
            name: "name",
            description: "description"
          }
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Creates an invite' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                training_provider_id: be_a(String),
                schema: Commands::CreateTrainingProvider::V1,
                data: {
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

    get 'Get all Training Providers' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retrieves all training provider' do
          before do
            create(:training_provider)
            create(:training_provider)
            create(:program)
          end

          schema type: :array,
                 items: {
                   "$ref" => "#/components/schemas/training_provider"
                 }

          run_test!
        end
      end
    end
  end

  path '/training_providers/{id}' do
    get 'Get a training provider' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      let(:id) { training_provider.id }
      let(:training_provider) { create(:training_provider) }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Retrieves the training provider' do
          schema "$ref" => "#/components/schemas/training_provider"

          run_test!
        end
      end
    end
  end
end
