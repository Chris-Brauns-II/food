require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Resumes", type: :request do
  path '/documents/resumes' do
    get "Get all resumes" do
      tags 'Documents'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: 'person_id',
                in: :query,
                type: :string,
                format: :uuid,
                required: false

      let(:person_id) { SecureRandom.uuid }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "spec unauthenticated openapi"

      context "when authenticated" do
        response '200', 'Returns all resumes' do
          schema type: :array,
                 items: {
                   "$ref" => "#/components/schemas/resume"
                 }

          before do
            create(:documents__resume, requestor_id: user.id, person_id: SecureRandom.uuid)
            create(:documents__resume, person_id: SecureRandom.uuid)
            create(:documents__resume, requestor_id: user.id)
          end

          context "when just a plain user" do
            include_context "authenticated openapi"

            before do
              expect(Documents::DocumentsQuery)
                .to receive(:all_resumes)
                .with(
                  person_id:,
                  requestor_id: user.id
                )
                .and_call_original
            end

            run_test!
          end

          context "when a coach" do
            include_context "coach authenticated openapi"

            before do
              expect(Documents::DocumentsQuery)
                .to receive(:all_resumes)
                .with(
                  person_id:
                )
                .and_call_original
            end

            run_test!
          end

          context "when a job order admin" do
            include_context "job order authenticated"

            before do
              expect(Documents::DocumentsQuery)
                .to receive(:all_resumes)
                .with(
                  person_id:
                )
                .and_call_original
            end

            run_test!
          end
        end
      end
    end

    post "Create a new resume" do
      tags 'Documents'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'resume_params',
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    personId: {
                      type: :string,
                      format: :uuid
                    },
                    anonymized: {
                      type: :boolean
                    },
                    documentKind: {
                      type: :string,
                      enum: Documents::DocumentKind::ALL
                    },
                    checks: {
                      type: :array,
                      items: {
                        type: :string,
                        enum: Documents::Checks::ALL
                      }
                    },
                    pageLimit: {
                      type: :integer,
                      minimum: 1
                    }
                  },
                  required: ['person_id']
                }

      let(:resume_params) do
        {
          personId: person_id,
          anonymized:,
          documentKind: document_kind,
          pageLimit: page_limit,
          checks:
        }
      end

      let(:person_id) { SecureRandom.uuid }
      let(:anonymized) { false }
      let(:document_kind) { Documents::DocumentKind::PDF }
      let(:page_limit) { 2 }
      let(:checks) { [Documents::Checks::DRUG] }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      context "when unauthenticated" do
        response '401', 'unauthenticated' do
          context "when not authenticated" do
            let(:Authorization) { nil }

            run_test!
          end

          context "when authenticated but requesting for a different person" do
            include_context "authenticated openapi"

            run_test!
          end
        end
      end

      context "when authenticated" do
        include_context "authenticated openapi"

        response '201', 'Creates a resume' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                resume_document_id: be_a(String),
                schema: Documents::Commands::GenerateResumeForPerson::V2,
                data: {
                  checks:,
                  person_id:,
                  anonymized:,
                  document_kind:,
                  page_limit:
                },
                metadata: {
                  requestor_type: Requestor::Kinds::USER,
                  requestor_id: user.id
                }
              )
              .and_call_original
          end

          context "when a regular requests for themselves" do
            before do
              user.update!(person_id:)
            end

            run_test!
          end

          context "when a coach requests for anyone" do
            include_context "coach authenticated openapi"

            run_test!
          end

          context "when a job order admin requests for anyone" do
            include_context "job order authenticated"

            run_test!
          end
        end
      end
    end
  end

  path '/documents/resumes/{id}' do
    get "Download a resume" do
      tags 'Documents'
      produces 'application/pdf'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { resume.id }
      let(:resume) { create(:documents__resume, requestor_id:, storage_kind: Documents::StorageKind::POSTGRES, storage_identifier: document.id, document_generated_at: Time.zone.now) }
      let(:document) { create(:document, file_name: "cool_resume.pdf") }
      let(:requestor_id) { SecureRandom.uuid }

      context "when unauthenticated" do
        response '401', 'unauthenticated' do
          context "when not authenticated" do
            let(:Authorization) { nil }

            run_test!
          end

          context "when authenticated but requesting for a different person" do
            include_context "authenticated openapi"

            run_test!
          end
        end
      end

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Download a file' do
          context "when a regular user requests for themselves" do
            let(:requestor_id) { user.id }

            run_test!
          end

          context "when a coach requests for anyone" do
            include_context "coach authenticated openapi"

            run_test!
          end

          context "when a job order admin requests for anyone" do
            include_context "job order authenticated"

            run_test!
          end
        end
      end
    end
  end
end
