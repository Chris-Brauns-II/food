require 'rails_helper'
require 'swagger_helper'

RSpec.describe "OtherExperiences", type: :request do
  path '/profiles/{seeker_id}/other_experiences' do
    post "Create experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :experience_params, in: :body, schema: {
        type: :object,
        properties: {
          otherExperience: {
            type: :object,
            properties: {
              organization_name: {
                type: :string
              },
              position: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              isCurrent: {
                type: :boolean
              },
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[otherExperience]
      }
      security [bearer_auth: []]

      let(:experience_params) do
        {
          otherExperience: {
            organizationName: organization_name,
            position:,
            startDate: start_date,
            endDate: end_date,
            isCurrent: is_current,
            description:
          }
        }
      end

      let(:seeker_id) { SecureRandom.uuid }
      let(:organization_name) { "Some org" }
      let(:position) { "great position" }
      let(:start_date) { "2020-10-15" }
      let(:end_date) { "2021-11-07" }
      let(:is_current) { false }
      let(:description) { "Some job" }

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
                schema: Events::ExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id: be_a(String),
                  organization_name:,
                  position:,
                  start_date:,
                  end_date:,
                  description:,
                  is_current:
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{seeker_id}/other_experiences/{id}' do
    put "Update experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :experience_params, in: :body, schema: {
        type: :object,
        properties: {
          otherExperience: {
            type: :object,
            properties: {
              organization_name: {
                type: :string
              },
              position: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              isCurrent: {
                type: :boolean
              },
              description: {
                type: :string
              }
            }
          }
        },
        required: %w[otherExperience]
      }
      security [bearer_auth: []]

      let(:experience_params) do
        {
          otherExperience: {
            organizationName: organization_name,
            position:,
            startDate: start_date,
            endDate: end_date,
            isCurrent: is_current,
            description:
          }
        }
      end

      let(:id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }

      let(:organization_name) { "Some org" }
      let(:position) { "great position" }
      let(:start_date) { "2020-10-15" }
      let(:end_date) { "2021-11-07" }
      let(:is_current) { false }
      let(:description) { "Some job" }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        let(:other_experience) { create(:other_experience, seeker:) }
        let(:id) { other_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Adds an experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::ExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id:,
                  organization_name:,
                  position:,
                  start_date:,
                  end_date:,
                  description:,
                  is_current:
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

        let(:other_experience) { create(:other_experience, seeker:) }
        let(:id) { other_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Removes a experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::ExperienceRemoved::V2,
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
