require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Questions", type: :request do
  path '/screeners/answers' do
    post "create new answers" do
      tags 'Screeners'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: :answers_params, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string
          },
          personId: {
            type: :string,
            format: :uuid
          },
          screenerQuestionsId: {
            type: :string,
            format: :uuid
          },
          questionResponses: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/question_response'
            }
          }
        },
        required: %w[title screenerQuestionId questionResponses]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:answers_params) do
        {
          title: "Sup",
          personId: person_id,
          screenerQuestionsId: screener_questions_id,
          questionResponses: [{ question: "How are you?", response: "Good" }]
        }
      end
      let(:person_id) { SecureRandom.uuid }
      let(:screener_questions_id) { SecureRandom.uuid }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '201', 'Creates new answers' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                screener_answers_id: be_a(String),
                schema: Screeners::Commands::CreateAnswers::V2,
                data: {
                  title: answers_params[:title],
                  screener_questions_id:,
                  person_id:,
                  question_responses: [Screeners::QuestionResponse.new(question: "How are you?", response: "Good")]
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

  path '/screeners/answers/{id}' do
    get "get a set of answers" do
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

        response '200', 'Returns the answers' do
          schema '$ref' => '#/components/schemas/answers'

          let(:answers) { create(:screeners__answers) }
          let(:id) { answers.id }

          run_test!
        end
      end
    end

    put "update a set of answers" do
      tags 'Screeners'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: :answers_params, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string
          },
          questionResponses: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/question_response'
            }
          }
        },
        required: %w[title screenerQuestionId questionResponses]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:id) { SecureRandom.uuid }
      let(:answers_params) do
        {
          title: "Sup",
          questionResponses: [{ question: "How are you?", response: "Good" }]
        }
      end

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Creates new answers' do
          before do
            expect_any_instance_of(MessageService)
              .to receive(:create!)
              .with(
                trace_id: be_a(String),
                screener_answers_id: id,
                schema: Screeners::Commands::UpdateAnswers::V1,
                data: {
                  title: answers_params[:title],
                  question_responses: [Screeners::QuestionResponse.new(question: "How are you?", response: "Good")]
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
