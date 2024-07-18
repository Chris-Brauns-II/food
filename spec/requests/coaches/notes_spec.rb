require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Notes", type: :request do
  path '/coaches/contexts/{id}/notes' do
    post "create a note" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :string
          },
          note_id: {
            type: :string,
            format: :uuid
          }
        },
        required: %w[note]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:id) { person_context.id }
      let(:note_params) do
        {
          note:,
          note_id:
        }
      end
      let(:note_id) { SecureRandom.uuid }
      let(:note) { "A note" }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        response '202', 'Creates a note' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:add_note)
              .with(originator: coach.email, person_id: id, note:, note_id:, trace_id: be_a(String))
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/coaches/contexts/{id}/notes/{note_id}' do
    put "modify a note" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :note_id, in: :path, type: :string
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :string
          }
        },
        required: %w[context_id note]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:id) { person_context.id }
      let(:note_params) do
        {
          note:
        }
      end
      let(:note_id) { SecureRandom.uuid }
      let(:note) { "A note" }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        before do
          create(:coaches__person_note, id: note_id)
        end

        response '202', 'Creates a note' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:modify_note)
              .with(originator: coach.email, person_id: id, note:, note_id:, trace_id: be_a(String))
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete "remove a note" do
      tags 'Coaches'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :note_id, in: :path, type: :string
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :string
          }
        },
        required: %w[context_id note]
      }
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "coach spec unauthenticated openapi"

      let(:person_context) { create(:coaches__person_context) }
      let(:id) { person_context.id }
      let(:note_params) do
        {
          note:
        }
      end
      let(:note_id) { SecureRandom.uuid }
      let(:note) { "A note" }

      context "when authenticated" do
        include_context "coach authenticated openapi"

        before do
          create(:coaches__person_note, id: note_id)
        end

        response '202', 'Creates a note' do
          before do
            expect_any_instance_of(Coaches::CoachesEventEmitter)
              .to receive(:delete_note)
              .with(
                person_id: id,
                originator: coach.email,
                note_id:,
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
