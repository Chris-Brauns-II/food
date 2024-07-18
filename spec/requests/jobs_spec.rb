require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Jobs", type: :request do
  path '/jobs/{id}' do
    get "Show a job" do
      tags 'Seeker'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let(:id) { job.id }

      response '200', 'Retreives a job' do
        schema '$ref' => '#/components/schemas/job'

        context "when job is basically empty" do
          let(:job) { create(:job) }
          let(:id) { job.id }

          run_test!
        end

        context "when job is fully loaded" do
          before do
            create(:career_path, job:)
            create(:learned_skill, job:)
            create(:desired_skill, job:)
            create(:desired_certification, job:)
            create(:job_photo, job:)
            create(:testimonial, job:)
            create(:job_tag, job:)
          end

          let(:job) { create(:job) }
          let(:id) { job.id }

          run_test!
        end

        context "when authenticated with an application" do
          before do
            create(:career_path, job:)
            create(:learned_skill, job:)
            create(:desired_skill, job:)
            create(:desired_certification, job:)
            create(:job_photo, job:)
            create(:testimonial, job:)
            create(:job_tag, job:)
            create(:applicant, job_id: job.id, seeker_id: seeker.id)
          end

          include_context "seeker authenticated openapi"

          let(:job) { create(:job) }
          let(:id) { job.id }

          run_test!
        end
      end

      response '404', 'Job not found' do
        schema '$ref' => '#/components/schemas/not_found'

        context "when the job doesn't exist" do
          let(:id) { SecureRandom.uuid }

          run_test!
        end

        context "when the job is hidden" do
          let(:job) { create(:job, hide_job: true) }
          let(:id) { job.id }

          run_test!
        end
      end
    end
  end

  path '/jobs/{id}/apply' do
    post "Apply to a job" do
      tags 'Seeker'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      let(:job) { create(:job) }
      let(:id) { job.id }

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Applies to a job' do
          before do
            seeker = create(:seeker, user_id: user.id)
            create(:job_search__job, job_id: id)
            create(:employers_job, job_id: id)

            expect(Seekers::ApplicationService)
              .to receive(:apply)
              .with(seeker:, job:, message_service: be_a(MessageService))
              .and_call_original
          end

          let(:job) { create(:job) }
          let(:id) { job.id }

          run_test!
        end

        response '404', 'Job not found job' do
          schema '$ref' => '#/components/schemas/not_found'

          context "when the job doesn't exist" do
            let(:id) { SecureRandom.uuid }

            run_test!
          end

          context "when the job is hidden" do
            let(:job) { create(:job, hide_job: true) }
            let(:id) { job.id }

            run_test!
          end
        end
      end
    end
  end

  path '/jobs/{id}/elevator_pitch' do
    post "Provide an elevator pitch for an application" do
      tags 'Seeker'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :pitch_params, in: :body, schema: {
        type: :object,
        properties: {
          elevator_pitch: {
            type: :string
          }
        },
        required: %w[elevator_pitch]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      let(:job) { create(:job) }
      let(:id) { job.id }
      let(:pitch_params) { { elevator_pitch: } }
      let(:elevator_pitch) { "A great pitch" }

      context "when authenticated" do
        include_context "authenticated openapi"

        response '202', 'Add elevator pitch' do
          before do
            seeker = create(:seeker, user_id: user.id)
            create(:applicant, seeker:, job_id: job.id)

            expect(Seekers::JobService)
              .to receive(:new)
              .with(job:, seeker:)
              .and_call_original

            expect_any_instance_of(Seekers::JobService)
              .to receive(:add_elevator_pitch)
              .with(elevator_pitch)
              .and_call_original
          end

          let(:job) { create(:job) }
          let(:id) { job.id }

          run_test!
        end

        response '404', 'Job not found job' do
          schema '$ref' => '#/components/schemas/not_found'

          context "when the job doesn't exist" do
            let(:id) { SecureRandom.uuid }

            run_test!
          end

          context "when the job is hidden" do
            let(:job) { create(:job, hide_job: true) }
            let(:id) { job.id }

            run_test!
          end
        end
      end
    end
  end
end
