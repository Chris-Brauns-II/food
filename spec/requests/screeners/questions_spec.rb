require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Questions", type: :request do
  path '/screeners/questions' do
    post "create new questions" do
      tags 'Screeners'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: :questions_params, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string
          },
          questions: {
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: %w[title questions]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:questions_params) do
        {
          title: "Sup",
          questions: ["How are you?"]
        }
      end

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '201', 'Creates new questions' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                screener_questions_id: be_a(String),
                schema: Screeners::Commands::CreateQuestions::V1,
                data: {
                  title: questions_params[:title],
                  questions: questions_params[:questions]
                },
                metadata: {
                  requestor_type: Requestor::Kinds::USER,
                  requestor_id: user.id,
                  requestor_email: user.email
                }
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    get "retrieve all questions" do
      tags 'Screeners'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '200', 'Returns the questions' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/questions'
                 }

          before do
            create(:screeners__questions)
            create(:screeners__questions)
            create(:screeners__questions)
          end

          run_test!
        end
      end
    end
  end

  path '/screeners/questions/{id}' do
    get "get a set of questions" do
      tags 'Screeners'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { SecureRandom.uuid }

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '404', 'Job Order not found' do
          let(:id) { SecureRandom.uuid }

          run_test!
        end

        response '200', 'Returns the questions' do
          schema '$ref' => '#/components/schemas/questions'

          let(:questions) { create(:screeners__questions) }
          let(:id) { questions.id }

          run_test!
        end
      end
    end

    put "update a set of questions" do
      tags 'Screeners'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: :questions_params, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string
          },
          questions: {
            type: :array,
            items: {
              type: :string
            }
          }
        },
        required: %w[title questions]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:id) { SecureRandom.uuid }
      let(:questions_params) do
        {
          title: "Sup",
          questions: ["How are you?"]
        }
      end

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Updates the questions' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                screener_questions_id: id,
                schema: Screeners::Commands::UpdateQuestions::V1,
                data: {
                  title: questions_params[:title],
                  questions: questions_params[:questions]
                },
                metadata: {
                  requestor_type: Requestor::Kinds::USER,
                  requestor_id: user.id,
                  requestor_email: user.email
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
