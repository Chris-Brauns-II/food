require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Admin::Jobs", type: :request do
  path '/admin/jobs' do
    get "Retreives all jobs" do
      tags 'Admin'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin authenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retreives all jobs' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :string, format: :uuid },
                     category: { type: :string },
                     employerId: { type: :string, format: :uuid },
                     employmentTitle: { type: :string },
                     benefitsDescription: { type: :string },
                     responsibilitiesDescription: { type: :string },
                     requirementsDescription: { type: :string },
                     location: { type: :string },
                     employmentType: { type: :string },
                     employer: {
                       type: :object,
                       properties: {
                         id: { type: :string, format: :uuid },
                         name: { type: :string },
                         bio: { type: :string },
                         location: { type: :string },
                         logoUrl: { type: :string },
                         chatEnabled: { type: :boolean },
                         createdAt: { type: :string, format: :date_time },
                         updatedAt: { type: :string, format: :date_time }
                       }
                     },
                     hideJob: { type: :boolean },
                     schedule: { type: :string },
                     workDays: { type: :string },
                     industry: { type: :array, items: { type: :string } },
                     careerPaths: {
                       type: :array, items: {
                         type: :object,
                         properties: {
                           id: { type: :string, format: :uuid },
                           name: { type: :string },
                           lower_limit: { type: :string },
                           upper_limit: { type: :string },
                           createdAt: { type: :string, format: :date_time },
                           updatedAt: { type: :string, format: :date_time }
                         }
                       }
                     },
                     desiredCertifications: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :string, format: :uuid },
                           name: { type: :string },
                           description: { type: :string },
                           createdAt: { type: :string, format: :date_time },
                           updatedAt: { type: :string, format: :date_time }
                         }
                       }
                     },
                     testimonials: { type: :array, items: { type: :object } },
                     jobPhotos: { type: :array, items: { type: :object } },
                     jobTag: { type: :array, items: { type: :object } },
                     learnedSkills: { type: :array, items: { type: :object } },
                     desiredSkills: { type: :array, items: { type: :object } },
                     createdAt: { type: :string, format: :date_time },
                     updatedAt: { type: :string, format: :date_time }
                   }
                 }

          let!(:job) do
            create(
              :job,
              responsibilities_description: "responsibilities",
              schedule: "schedule",
              work_days: "work days",
              requirements_description: "reqs"
            )
          end

          run_test!
        end
      end
    end
  end

  path '/admin/jobs/{id}' do
    get "Show a job" do
      tags 'Admin'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let(:id) { job.id }

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Retreives a job' do
          schema '$ref' => '#/components/schemas/admin_job'

          context "when job is fully loaded" do
            before do
              create(:job_attribute, job:)
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
        end
      end
    end

    put 'Update a job' do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :job_params, in: :body, schema: {
        type: :object,
        properties: {
          job: {
            type: :object,
            properties: {
              category: {
                type: :string
              },
              employment_title: {
                type: :string
              },
              employer_id: {
                type: :string
              },
              location: {
                type: :string
              },
              benefits_description: {
                type: :string
              },
              responsibilities_description: {
                type: :string
              },
              employment_type: {
                type: :string
              },
              schedule: {
                type: :string
              },
              work_days: {
                type: :string
              },
              requirements_description: {
                type: :string
              },
              industry: {
                type: :array,
                items: {
                  type: :string
                }
              }
            }
          }
        },
        required: %w[category employment_title employer_id location benefits_description responsibilities_description employment_type schedule work_days requirements_description industry]
      }
      let(:id) { job.id }
      let(:job) { create(:job) }
      let(:job_params) do
        {
          category: Job::Categories::STAFFING,
          employment_title: "Laborer",
          employer_id: job.employer.id,
          location: "Columbus, OH",
          benefits_description: "Benefits",
          responsibilities_description: "Responsibilities",
          employment_type: "FULLTIME",
          schedule: "9-5",
          work_days: "M-F",
          requirements_description: "Requirements",
          industry: [Job::Industries::MANUFACTURING]
        }
      end

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin authenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'Job updated' do
          before do
            expect_any_instance_of(Jobs::JobService)
              .to receive(:update)
              .with(
                job_id: job.id,
                category: Job::Categories::STAFFING,
                employment_title: "Laborer",
                benefits_description: "Benefits",
                hide_job: false,
                responsibilities_description: "Responsibilities",
                location: "Columbus, OH",
                employment_type: "FULLTIME",
                schedule: "9-5",
                work_days: "M-F",
                requirements_description: "Requirements",
                industry: [Job::Industries::MANUFACTURING]
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/admin/jobs' do
    post "Create a job" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :job_params, in: :body, schema: {
        type: :object,
        properties: {
          job: {
            type: :object,
            properties: {
              category: {
                type: :string
              },
              employment_title: {
                type: :string
              },
              employer_id: {
                type: :string
              },
              location: {
                type: :string
              },
              benefits_description: {
                type: :string
              },
              responsibilities_description: {
                type: :string
              },
              employment_type: {
                type: :string
              },
              schedule: {
                type: :string
              },
              work_days: {
                type: :string
              },
              requirements_description: {
                type: :string
              },
              industry: {
                type: :array,
                items: {
                  type: :string
                }
              }
            }
          }
        },
        required: %w[category employment_title employer_id location benefits_description responsibilities_description employment_type schedule work_days requirements_description industry]
      }
      let(:job_params) do
        {
          category: Job::Categories::STAFFING,
          employment_title: "Laborer",
          employer_id: employer.id,
          location: "Columbus, OH",
          benefits_description: "Benefits",
          responsibilities_description: "Responsibilities",
          employment_type: "FULLTIME",
          schedule: "9-5",
          work_days: "M-F",
          requirements_description: "Requirements",
          industry: [Job::Industries::MANUFACTURING]
        }
      end
      let(:employer) { create(:employer) }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin authenticated openapi"

      context "when authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Job created' do
          before do
            expect_any_instance_of(Jobs::JobService)
              .to receive(:create)
              .with(
                category: Job::Categories::STAFFING,
                employment_title: "Laborer",
                employer_id: employer.id,
                location: "Columbus, OH",
                benefits_description: "Benefits",
                responsibilities_description: "Responsibilities",
                employment_type: "FULLTIME",
                schedule: "9-5",
                work_days: "M-F",
                requirements_description: "Requirements",
                industry: [Job::Industries::MANUFACTURING],
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
