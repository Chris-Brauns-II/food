require 'rails_helper'
require 'swagger_helper'

RSpec.describe "JobOrders", type: :request do
  path '/job_orders/orders/{order_id}/notes' do
    post "create a new note" do
      tags 'Job Orders'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'order_id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :string
          }
        },
        required: %w[note]
      }
      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:order_id) { job_order.id }
      let(:note) { "Some note" }
      let(:note_params) { { note: } }
      let(:job_order) { create(:job_orders__job_order) }

      context "when authenticated" do
        include_context "job order authenticated"

        response '201', 'Create a new note' do
          let(:context_id) { reminder_context_id }

          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:add_note)
              .with(
                job_order_id: order_id,
                originator: user.email,
                note_id: be_a(String),
                note:,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end
  end

  path '/job_orders/orders/{order_id}/notes/{id}' do
    put "update a note" do
      tags 'Job Orders'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: 'order_id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          note: {
            type: :string
          }
        },
        required: %w[note]
      }
      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:order_id) { job_order.id }
      let(:id) { existing_note.id }
      let(:note) { "Some note" }
      let(:note_params) { { note: } }
      let(:job_order) { create(:job_orders__job_order) }
      let(:existing_note) { create(:job_orders__note, job_order:) }

      context "when authenticated" do
        include_context "job order authenticated"

        response '202', 'Update a note' do
          let(:context_id) { reminder_context_id }

          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:modify_note)
              .with(
                job_order_id: order_id,
                originator: user.email,
                note_id: id,
                note:,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          run_test!
        end
      end
    end

    delete "delete a note" do
      tags 'Job Orders'
      security [bearer_auth: []]

      parameter name: 'order_id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:order_id) { job_order.id }
      let(:id) { existing_note.id }
      let(:job_order) { create(:job_orders__job_order) }
      let(:existing_note) { create(:job_orders__note, job_order:) }

      context "when authenticated" do
        include_context "job order authenticated"

        response '202', 'Remove a note' do
          let(:context_id) { reminder_context_id }

          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:remove_note)
              .with(
                job_order_id: order_id,
                originator: user.email,
                note_id: id,
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
