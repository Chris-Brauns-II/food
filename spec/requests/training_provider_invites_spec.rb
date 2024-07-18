require 'rails_helper'
require 'swagger_helper'

RSpec.describe "TrainingProviderInvites", type: :request do
  path '/training_provider_invites' do
    post 'Create an Training Provider Invite' do
      tags 'Admin'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :invite_params, in: :body, schema: {
        type: :object,
        properties: {
          email: {
            type: :string
          },
          firstName: {
            type: :string
          },
          lastName: {
            type: :string
          },
          roleDescription: {
            type: :string
          },
          trainingProviderId: {
            type: :string,
            format: :uuid
          }
        },
        required: %w[email firstName lastName roleDescription trainingProviderId]
      }

      let(:invite_params) do
        {
          email: "email",
          firstName: "firstName",
          lastName: "lastName",
          roleDescription: "roleDescription",
          trainingProviderId: SecureRandom.uuid
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
                invite_id: be_a(String),
                schema: Commands::CreateTrainingProviderInvite::V1,
                data: {
                  invite_email: "email",
                  first_name: "firstName",
                  last_name: "lastName",
                  role_description: "roleDescription",
                  training_provider_id: invite_params[:trainingProviderId]
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    get 'Get all invites' do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retrieves a program' do
          before do
            create(:invites__training_provider_invite)
            create(:invites__training_provider_invite)
            create(:invites__training_provider_invite)
          end

          schema type: :array,
                 items: {
                   "$ref" => "#/components/schemas/training_provider_invite"
                 }

          run_test!
        end
      end
    end
  end

  path '/training_provider_invites/{id}/used' do
    put 'Use a Training Provider Invite' do
      tags 'Admin'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:id) { SecureRandom.uuid }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '202', 'Uses the invite' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                invite_id: id,
                trace_id: be_a(String),
                schema: Commands::AcceptTrainingProviderInvite::V1,
                data: {
                  user_id: user.id
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
