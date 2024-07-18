require 'rails_helper'
require 'swagger_helper'

RSpec.describe "JobOrders", type: :request do
  path '/job_orders/orders/{id}/candidates/{person_id}' do
    put "updates a candidate status" do
      tags 'Job Orders'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: 'person_id',
                in: :path,
                type: :string,
                format: :uuid
      parameter name: 'update_params',
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    status: { type: :string, enum: JobOrders::CandidateStatus::ALL }
                  },
                  required: ['status']
                }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      let(:job_order) { create(:job_orders__job_order) }
      let(:id) { job_order.id }
      let(:candidate) { create(:job_orders__candidate, job_order:) }
      let(:person_id) { candidate.person_id } # See TODO on controller

      let(:update_params) do
        {
          status:
        }
      end
      let(:status) { "interviewing" }

      context "when authenticated" do
        include_context "job order authenticated"

        let(:status) { "interviewing" }

        response '204', 'Updates a candidate status' do
          let(:context_id) { reminder_context_id }

          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:update_status)
              .with(
                job_order_id: id,
                person_id: candidate.person_id,
                status:,
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
