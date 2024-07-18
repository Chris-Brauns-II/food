require 'rails_helper'
require 'swagger_helper'

RSpec.describe "DesiredCertifications", type: :request do
  path '/jobs/{job_id}/desired_certifications' do
    post "Add a desired certification" do
      tags 'Admin'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: :job_id, in: :path, type: :string
      parameter name: :desired_certification_params, in: :body, schema: {
        type: :object,
        properties: {
          masterCertificationId: { type: :string }
        },
        required: ['masterCertificationId']
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:desired_certification_params) { { masterCertificationId: SecureRandom.uuid } }
      let(:job_id) { SecureRandom.uuid }

      it_behaves_like "admin spec unauthenticated openapi"

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '201', 'Request certification added' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                job_id:,
                schema: Commands::AddDesiredCertification::V1,
                data: {
                  id: be_a(String),
                  master_certification_id: desired_certification_params[:masterCertificationId]
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/jobs/{job_id}/desired_certifications/{id}' do
    delete "Removes a desired certification" do
      tags 'Admin'
      security [bearer_auth: []]
      parameter name: :job_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "admin spec unauthenticated openapi"

      let(:id) { SecureRandom.uuid }
      let(:job_id) { SecureRandom.uuid }

      context "admin authenticated" do
        include_context "admin authenticated openapi"

        response '202', 'desired skill destroyed' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                job_id:,
                schema: Commands::RemoveDesiredCertification::V1,
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
