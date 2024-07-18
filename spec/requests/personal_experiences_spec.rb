require 'rails_helper'
require 'swagger_helper'

RSpec.describe "PersonalExperiences", type: :request do
  path '/profiles/{seeker_id}/personal_experiences' do
    post "Create experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :personal_params, in: :body, schema: {
        type: :object,
        properties: {
          personalExperience: {
            type: :object,
            properties: {
              activity: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[personalExperience]
      }
      security [bearer_auth: []]

      let(:personal_params) do
        {
          personalExperience: {
            activity:,
            startDate: start_date,
            endDate: end_date,
            description:
          }
        }
      end

      let(:seeker_id) { SecureRandom.uuid }
      let(:activity) { "Picking up sticks" }
      let(:start_date) { "May" }
      let(:end_date) { "Sam I am" }
      let(:description) { "111" }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        let(:seeker_id) { seeker.id }

        response '201', 'Create an experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::PersonalExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id: be_a(String),
                  activity:,
                  start_date:,
                  end_date:,
                  description:
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{seeker_id}/personal_experiences/{id}' do
    put "Update experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :personal_params, in: :body, schema: {
        type: :object,
        properties: {
          personalExperience: {
            type: :object,
            properties: {
              activity: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[personalExperience]
      }
      security [bearer_auth: []]

      let(:personal_params) do
        {
          personalExperience: {
            activity:,
            startDate: start_date,
            endDate: end_date,
            description:
          }
        }
      end

      let(:id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }

      let(:activity) { "Picking up sticks" }
      let(:start_date) { "May" }
      let(:end_date) { "Sam I am" }
      let(:description) { "111" }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        let(:personal_experience) { create(:personal_experience, seeker:) }
        let(:id) { personal_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Adds an experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::PersonalExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id:,
                  activity:,
                  start_date:,
                  end_date:,
                  description:
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete "Remove experience" do
      tags "Seekers"
      security [bearer_auth: []]
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      let(:id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        let(:personal_experience) { create(:personal_experience, seeker:) }
        let(:id) { personal_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Removes a experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::PersonalExperienceRemoved::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id:
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
