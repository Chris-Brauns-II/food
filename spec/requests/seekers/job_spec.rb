require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Seekers::JobsController", type: :request do
  path '/seekers/jobs' do
    get "Search jobs" do
      tags "Seekers"
      produces "application/json"
      security [bearer_auth: []]
      parameter name: :utm_term, in: :query, type: :string, required: false
      parameter name: :utm_source, in: :query, type: :string, required: false

      parameter name: 'industries[]',
                in: :query,
                type: :array,
                style: :form,
                explode: true,
                items: {
                  type: :string
                },
                required: false
      parameter name: 'tags[]',
                in: :query,
                type: :array,
                style: :form,
                explode: true,
                items: {
                  type: :string
                },
                required: false

      before do
        create_list(:job_search__job, 4)
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:search_service) { JobSearch::JobSearchQuery.new }

      response '200', 'search executed' do
        schema type: :array,
               items: {
                 '$ref' => '#/components/schemas/search_job'
               }

        context "when unauthenticated" do
          let(:Authorization) { nil }

          context "When called without parameters" do
            before do
              expect_any_instance_of(JobSearch::JobSearchQuery)
                .to receive(:search)
                .with(
                  search_terms: nil,
                  industries: nil,
                  tags: nil,
                  user: nil,
                  utm_source: nil
                ).and_call_original
            end

            run_test!
          end

          context "When called with query parameters" do
            before do
              expect_any_instance_of(JobSearch::JobSearchQuery)
                .to receive(:search)
                .with(
                  search_terms: "Best Job",
                  industries: ["Clowning"],
                  tags: ["Funny clowns only"],
                  user: nil,
                  utm_source:
                ).and_call_original
            end

            let(:utm_term) { "Best Job" }
            let(:utm_source) { "www.google.com" }
            let('industries[]') { ["Clowning"] }
            let('tags[]') { ["Funny clowns only"] }

            run_test!
          end
        end

        context "when authenticated" do
          before do
            create(:job_search__saved_job, user_id: user.id)
            create(:job_search__application, seeker_id: seeker.id)
          end

          include_context "seeker authenticated openapi"

          context "When called without parameters" do
            before do
              expect_any_instance_of(JobSearch::JobSearchQuery)
                .to receive(:search)
                .with(
                  search_terms: nil,
                  industries: nil,
                  tags: nil,
                  user:,
                  utm_source: nil
                ).and_call_original
            end

            run_test!
          end

          context "When called with query parameters" do
            before do
              expect_any_instance_of(JobSearch::JobSearchQuery)
                .to receive(:search)
                .with(
                  search_terms: "Best Job",
                  industries: ["Clowning"],
                  tags: ["Funny clowns only"],
                  user:,
                  utm_source: "www.google.com"
                ).and_call_original
            end

            let(:utm_term) { "Best Job" }
            let(:utm_source) { "www.google.com" }
            let('industries[]') { ["Clowning"] }
            let('tags[]') { ["Funny clowns only"] }

            run_test!
          end
        end
      end
    end
  end

  path '/seekers/jobs/{id}/save' do
    post "Save a job" do
      tags "Seekers"
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let!(:search_job) { create(:job_search__job, job_id: job.id) }
      let(:id) { job.id }

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        response '202', 'saves a job' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::JobSaved::V1,
                user_id: user.id,
                data: {
                  job_id: job.id,
                  employment_title: job.employment_title,
                  employer_name: job.employer.name
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/seekers/jobs/{id}/unsave' do
    post "Save a job" do
      tags "Seekers"
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let!(:search_job) { create(:job_search__job, job_id: job.id) }
      let(:id) { job.id }

      it_behaves_like "seeker spec unauthenticated openapi"

      context "when authenticated" do
        include_context "seeker authenticated openapi"

        response '202', 'saves a job' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                schema: Events::JobUnsaved::V1,
                user_id: user.id,
                data: {
                  job_id: job.id,
                  employment_title: job.employment_title,
                  employer_name: job.employer.name
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
