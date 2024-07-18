require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Screener", type: :request do
  path '/documents/screeners' do
    get "Get all screeners" do
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
                   "$ref" => "#/components/schemas/screener"
                 }

          before do
            create(:documents__screener, person_id: SecureRandom.uuid)
            create(:documents__screener, person_id: SecureRandom.uuid)
            create(:documents__screener)
          end

          context "when a coach" do
            include_context "coach authenticated openapi"

            before do
              expect(Documents::DocumentsQuery)
                .to receive(:all_screeners)
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
                .to receive(:all_screeners)
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

    post "Create a new screener" do
      tags 'Documents'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'screener_params',
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    screenerAnswersId: {
                      type: :string,
                      format: :uuid
                    }
                  },
                  required: ['person_id']
                }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:screener_params) do
        {
          screenerAnswersId: screener_answers_id
        }
      end
      let(:screener_answers_id) { SecureRandom.uuid }

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        response '202', 'Returns the answers' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                screener_document_id: be_a(String),
                schema: Documents::Commands::GenerateScreenerForAnswers::V1,
                data: {
                  screener_answers_id:,
                  document_kind: Documents::DocumentKind::PDF
                },
                metadata: {
                  requestor_type: Requestor::Kinds::USER,
                  requestor_id: user.id,
                  requestor_email: user.email
                }
              )
              .and_call_original
          end

          context "when a coach" do
            include_context "coach authenticated openapi"

            run_test!
          end

          context "when a job order admin" do
            include_context "job order authenticated"

            run_test!
          end
        end
      end
    end
  end

  path '/documents/screeners/{id}' do
    get "Download a screener" do
      tags 'Documents'
      produces 'application/pdf'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { screener.id }
      let(:screener) { create(:documents__screener, requestor_id:, storage_kind: Documents::StorageKind::POSTGRES, storage_identifier: document.id, document_generated_at: Time.zone.now) }
      let(:document) { create(:document, file_name: "cool_screeners.pdf") }
      let(:requestor_id) { SecureRandom.uuid }

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "authenticated openapi"

        response '200', 'Download a file' do
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
