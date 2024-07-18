require 'rails_helper'
require 'swagger_helper'

RSpec.describe "EmployerInvites", type: :request do
  path '/employer_invites' do
    post "Create an invite" do
      tags 'Invite'
      consumes 'application/json'
      parameter name: :invite_params, in: :body, schema: {
        type: :object,
        properties: {
          email: {
            type: :string
          },
          employer_id: {
            type: :string,
            format: :uuid
          },
          first_name: {
            type: :string
          },
          last_name: {
            type: :string
          }
        },
        required: %w[email employer_id first_name last_name]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      let(:invite_params) do
        {
          email:,
          employer_id:,
          first_name:,
          last_name:
        }
      end
      let(:email) { "company@lame.com" }
      let(:employer_id) { SecureRandom.uuid }
      let(:first_name) { "First" }
      let(:last_name) { "Last" }

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Create an invite' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Commands::CreateEmployerInvite::V1,
                trace_id: be_a(String),
                invite_id: be_a(String),
                data: {
                  invite_email: email,
                  employer_id:,
                  first_name:,
                  last_name:
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    get "Get all invites" do
      tags 'Invite'
      produces 'application/json'

      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Returns invites' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/employer_invite'
                 }

          before do
            create(:invites__employer_invite)
            create(:invites__employer_invite)
          end

          run_test!
        end
      end
    end
  end

  path '/employer_invites/{id}/used' do
    put "Use an invite" do
      tags 'Invite'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      let(:id) { SecureRandom.uuid }

      context "when authenticated" do
        include_context "authenticated openapi"

        response '202', 'Uses an invite' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Commands::AcceptEmployerInvite::V1,
                trace_id: be_a(String),
                invite_id: id,
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
