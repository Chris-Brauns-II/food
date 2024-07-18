require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Employers::Jobs", type: :request do
  path '/employers/jobs' do
    get "Retrieve employer jobs" do
      tags 'Employers'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "employer spec unauthenticated openapi"

      context "when authenticated" do
        before do
          job1 = create(:job, employer:)
          job2 = create(:job, employer:)

          employers_job1 = create(:employers_job, employer: employers_employer, employment_title: job1.employment_title)
          employers_job2 = create(:employers_job, employer: employers_employer, employment_title: job2.employment_title)

          create(:applicant, job_id: job1.id)
          create(:applicant, job_id: job2.id)
          create(:applicant, job_id: job2.id)

          create(:employers_applicant, job: employers_job1)
          create(:employers_applicant, job: employers_job2)
        end

        include_context "employer authenticated openapi"

        response '200', 'jobs retrieved' do
          schema type: :object,
                 properties: {
                   jobs: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: {
                           type: :string,
                           format: :uuid
                         },
                         employerId: {
                           type: :string,
                           format: :uuid
                         },
                         employerName: {
                           type: :string
                         },
                         name: {
                           type: :string
                         },
                         description: {
                           type: :string
                         }
                       }

                     }
                   },
                   applicants: {
                     type: :array,
                     items: {
                       '$ref' => '#/components/schemas/employer_applicants'
                     }
                   }
                 },
                 required: %w[jobs applicants]

          before do
            expect(Employers::EmployerQuery)
              .to receive(:new)
              .with(employers: [employers_employer])
              .and_call_original

            expect_any_instance_of(Employers::EmployerQuery)
              .to receive(:all_jobs)
              .and_call_original

            expect_any_instance_of(Employers::EmployerQuery)
              .to receive(:all_applicants)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
