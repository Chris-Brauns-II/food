require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Employers::Applicants", type: :request do
  path '/employers/applicants/{id}' do
    put "Update an applicants status" do
      tags 'Employers'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :update, in: :body, schema: {
        type: :object,
        properties: {
          status: {
            type: :string,
            enum: ApplicantStatus::StatusTypes::ALL
          },
          reasons: {
            nullable: true,
            type: :array,
            items: {
              oneOf: [
                {
                  type: :string
                },
                {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    response: {
                      type: :string,
                      format: :uuid
                    }
                  }
                }
              ]
            }
          }
        },
        required: %w[status]
      }

      before do
        message_service.create!(
          schema: Events::EmployerCreated::V1,
          employer_id:,
          data: {
            name: "Blocktrain",
            location: "Columbus, OH",
            bio: "We are a welding company",
            logo_url: "https://www.blocktrain.com/logo.png"
          }
        )
        message_service.create!(
          schema: Events::JobCreated::V3,
          job_id:,
          data: {
            category: Job::Categories::MARKETPLACE,
            employment_title: "Laborer",
            employer_name: "Employer",
            employer_id:,
            benefits_description: "Benefits",
            responsibilities_description: "Responsibilities",
            location: "Columbus, OH",
            employment_type: "FULLTIME",
            hide_job: false,
            schedule: "9-5",
            work_days: "M-F",
            requirements_description: "Requirements",
            industry: [Job::Industries::MANUFACTURING]
          }
        )
        message_service.create!(
          schema: Events::ApplicantStatusUpdated::V6,
          application_id: id,
          data: {
            applicant_first_name: "John",
            applicant_last_name: "Chabot",
            applicant_email: "john@skillarc.com",
            applicant_phone_number: "3333333333",
            seeker_id:,
            user_id: SecureRandom.uuid,
            job_id:,
            employer_name: "Employer",
            employment_title: "Great title",
            status: ApplicantStatus::StatusTypes::NEW
          },
          metadata: {
            user_id: SecureRandom.uuid
          }
        )
      end

      let(:seeker) { create(:seeker) }
      let(:message_service) { MessageService.new }
      let(:application) { create(:employers_applicant) }
      let(:employer_id) { job.employer.id }
      let(:seeker_id) { seeker.id }
      let(:job) { create(:job) }
      let(:job_id) { job.id }
      let(:application_id) { SecureRandom.uuid }
      let(:id) { application.id }
      let(:status) { ApplicantStatus::StatusTypes::PENDING_INTRO }
      let(:reasons) { [{ id: create(:employers__pass_reason).id, response: "Bad canidate" }] }
      let(:update) do
        {
          status:,
          reasons:
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "employer spec unauthenticated openapi"

      context "when authenticated" do
        include_context "employer authenticated openapi"

        response '202', 'Applicant updated' do
          context "when reasons are given" do
            let(:reasons) { nil }

            before do
              expect(Employers::ApplicationService)
                .to receive(:update_status)
                .with(status:, user_id: user.id, application_id: id, reasons: [], message_service: be_a(MessageService))
                .and_call_original
            end

            run_test!
          end

          context "when reasons are not given" do
            let(:reasons) { [{ id: create(:employers__pass_reason).id, response: "Bad canidate" }] }

            before do
              expect(Employers::ApplicationService)
                .to receive(:update_status)
                .with(status:, user_id: user.id, application_id: id, reasons:, message_service: be_a(MessageService))
                .and_call_original
            end

            run_test!
          end
        end
      end
    end
  end
end
