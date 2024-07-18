require 'rails_helper'
require 'swagger_helper'

RSpec.describe "EducationExperiences", type: :request do
  path '/profiles/{seeker_id}/education_experiences' do
    post "Create experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :experience_params, in: :body, schema: {
        type: :object,
        properties: {
          educationExperience: {
            type: :object,
            properties: {
              organization_name: {
                type: :string
              },
              title: {
                type: :string
              },
              graduation_date: {
                type: :string
              },
              gpa: {
                type: :string
              },
              activities: {
                type: :string
              }
            }
          }
        },
        required: %w[educationExperience]
      }
      security [bearer_auth: []]

      let(:experience_params) do
        {
          educationExperience: {
            organizationName: organization_name,
            title:,
            graduationDate: graduation_date,
            gpa:,
            activities:
          }
        }
      end

      let(:seeker_id) { SecureRandom.uuid }
      let(:organization_name) { "Some org" }
      let(:title) { "great title" }
      let(:graduation_date) { "Last week" }
      let(:gpa) { "Dude" }
      let(:activities) { "!!!" }

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
                schema: Events::EducationExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id: be_a(String),
                  organization_name:,
                  title:,
                  gpa:,
                  activities:,
                  graduation_date:
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/profiles/{seeker_id}/education_experiences/{id}' do
    put "Update experience" do
      tags "Seekers"
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :seeker_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :experience_params, in: :body, schema: {
        type: :object,
        properties: {
          educationExperience: {
            type: :object,
            properties: {
              organization_name: {
                type: :string
              },
              title: {
                type: :string
              },
              graduation_date: {
                type: :string
              },
              gpa: {
                type: :string
              },
              activities: {
                type: :string
              }
            }
          }
        },
        required: %w[educationExperience]
      }
      security [bearer_auth: []]

      let(:experience_params) do
        {
          educationExperience: {
            organizationName: organization_name,
            title:,
            graduationDate: graduation_date,
            gpa:,
            activities:
          }
        }
      end

      let(:id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }

      let(:seeker_id) { SecureRandom.uuid }
      let(:organization_name) { "Some org" }
      let(:title) { "great title" }
      let(:graduation_date) { "Last week" }
      let(:gpa) { "Dude" }
      let(:activities) { "!!!" }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        let(:education_experience) { create(:education_experience, seeker:) }
        let(:id) { education_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Adds an experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::EducationExperienceAdded::V2,
                person_id: seeker.id,
                trace_id: be_a(String),
                data: {
                  id:,
                  organization_name:,
                  title:,
                  gpa:,
                  activities:,
                  graduation_date:
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

        let(:education_experience) { create(:education_experience, seeker:) }
        let(:id) { education_experience.id }
        let(:seeker_id) { seeker.id }

        response '202', 'Removes a experience' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::EducationExperienceDeleted::V2,
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
