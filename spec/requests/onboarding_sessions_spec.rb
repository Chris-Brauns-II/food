require 'rails_helper'
require 'swagger_helper'

RSpec.describe "OnboardingSessions", type: :request do
  path "/onboarding_sessions" do
    post "Create new onboarding session" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :onboarding_create_params, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          phone_number: { type: :string },
          date_of_birth: { type: :string }
        },
        required: %w[first_name last_name phone_number date_of_birth]
      }

      let(:onboarding_create_params) do
        {
          first_name: "John",
          last_name: "Chabot",
          phone_number: "333-333-3333",
          date_of_birth: "10/09/1990"
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '201', 'Create an experience' do
          context "when there is already a person" do
            before do
              seeker = create(:seeker, user_id: user.id)
              user.update!(person_id: seeker.id)

              expect_any_instance_of(MessageService)
                .to receive(:create!)
                .with(
                  schema: Events::BasicInfoAdded::V1,
                  trace_id: be_a(String),
                  person_id: be_a(String),
                  data: {
                    first_name: "John",
                    last_name: "Chabot",
                    phone_number: "333-333-3333",
                    email: user.email
                  }
                )
                .and_call_original

              expect_any_instance_of(MessageService)
                .to receive(:create!)
                .with(
                  schema: Events::DateOfBirthAdded::V1,
                  trace_id: be_a(String),
                  person_id: be_a(String),
                  data: {
                    date_of_birth: "10/09/1990"
                  }
                )
                .and_call_original
            end

            run_test!
          end

          context "when there is not a seeker" do
            before do
              expect_any_instance_of(MessageService)
                .to receive(:create!)
                .with(
                  schema: Commands::AddPerson::V2,
                  trace_id: be_a(String),
                  person_id: be_a(String),
                  data: {
                    user_id: user.id,
                    first_name: "John",
                    last_name: "Chabot",
                    phone_number: "333-333-3333",
                    date_of_birth: "10/09/1990",
                    source_kind: People::SourceKind::USER,
                    source_identifier: user.id,
                    email: user.email
                  }
                )
                .and_call_original
            end

            run_test!
          end
        end
      end
    end

    get "Get the onboarding session" do
      tags "Seekers"
      security [bearer_auth: []]
      produces 'application/json'

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Returns the onboarding session' do
          schema '$ref' => '#/components/schemas/onboarding_session'

          run_test!
        end
      end
    end

    put "Update a onboarding session" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :onboarding_params, in: :body, schema: {
        type: :object,
        properties: {
          onboarding_session: {
            type: :object
          }
        },
        required: %w[onboarding_session]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      let(:onboarding_params) do
        {
          onboarding_session: {
            responses: {
              name: {
                response: {
                  firstName: "Hannah",
                  lastName: "Montana",
                  phoneNumber: "1234567890",
                  dateOfBirth: "01/01/2000"
                }
              }
            }
          }
        }
      end

      context "when authenticated" do
        include_context "authenticated openapi"

        response '400', 'Bad request no seeker' do
          schema schema: {
            type: :object,
            properties: {
              error: {
                type: :string
              }
            }
          }

          run_test!
        end

        response '200', 'Update the onboarding session' do
          schema '$ref' => '#/components/schemas/onboarding_session'

          before do
            seeker = create(:seeker, user_id: user.id)
            user.update!(person_id: seeker.id)
          end

          run_test!
        end
      end
    end
  end
end
