require 'rails_helper'
require 'swagger_helper'

RSpec.describe "DesiredSkills", type: :request do
  path '/jobs/{job_id}/desired_skills' do
    post "Create a desired skill" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :job_id, in: :path, type: :string
      parameter name: :desired_skill_params, in: :body, schema: {
        type: :object,
        properties: {
          master_skill_id: { type: :string }
        },
        required: ['master_skill_id']
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let(:job_id) { job.id }
      let(:master_skill) { create(:master_skill) }
      let(:desired_skill_params) do
        {
          master_skill_id: master_skill.id
        }
      end

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'desired skill created' do
          before do
            expect(Jobs::DesiredSkillService)
              .to receive(:create)
              .with(job, master_skill.id)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/jobs/{job_id}/desired_skills/{id}' do
    delete "Destroy a desired skill" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :job_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:job) { create(:job) }
      let(:job_id) { job.id }
      let(:desired_skill) { create(:desired_skill, job:) }
      let(:id) { desired_skill.id }

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '200', 'desired skill destroyed' do
          before do
            expect(Jobs::DesiredSkillService)
              .to receive(:destroy)
              .with(desired_skill)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
