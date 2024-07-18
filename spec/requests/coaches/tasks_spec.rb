require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Tasks", type: :request do
  path '/coaches/tasks' do
    get "get all coach tasks" do
      tags 'Coaches'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: 'context_id',
                in: :query,
                type: :string,
                format: :uuid,
                required: false

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '200', 'Returns all tasks' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/reminder'
                 }

          let(:reminder_person_id) { SecureRandom.uuid }

          before do
            create(:coaches__reminder, coach:)
            create(:coaches__reminder, coach:, person_id: reminder_person_id)
          end

          context "when no context id is provided" do
            before do
              expect(Coaches::CoachesQuery)
                .to receive(:tasks)
                .with(coach:, person_id: nil)
                .and_call_original
            end

            run_test!
          end

          context "when a context id is provided" do
            let(:context_id) { reminder_person_id }

            before do
              expect(Coaches::CoachesQuery)
                .to receive(:tasks)
                .with(coach:, person_id: reminder_person_id)
                .and_call_original
            end

            run_test!
          end
        end
      end
    end
  end

  path '/coaches/tasks/reminders' do
    post "create a reminder" do
      tags 'Coaches'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: :reminder_params, in: :body, schema: {
        type: :object,
        properties: {
          reminder: {
            type: :object,
            properties: {
              note: {
                type: :string
              },
              reminderAt: {
                type: :string,
                format: 'date-time'
              },
              contextId: {
                type: :string,
                format: :uuid
              }
            }
          },
          required: %w[reminderAt note]
        },
        required: %w[reminder]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:reminder_params) do
        {
          reminder: {
            note:,
            reminderAt: reminder_at.to_s,
            contextId: person_id
          }
        }
      end
      let(:note) { "A note" }
      let(:reminder_at) { Time.zone.local(2025, 1, 1) }
      let(:person_id) { SecureRandom.uuid }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Creates a reminder' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:create_reminder)
              .with(coach:, note:, reminder_at:, person_id:, trace_id: be_a(String))
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/coaches/tasks/reminders/{id}/complete' do
    put "complete a reminder" do
      tags 'Coaches'
      parameter name: :id, in: :path, type: :string
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:reminder) { create(:coaches__reminder) }
      let(:id) { reminder.id }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        let(:reminder) { create(:coaches__reminder, coach:) }

        response '202', 'Completes a reminder' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:complete_reminder)
              .with(coach:, reminder_id: id, trace_id: be_a(String))
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
