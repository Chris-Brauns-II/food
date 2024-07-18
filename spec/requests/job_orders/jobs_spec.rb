require 'rails_helper'
require 'swagger_helper'

RSpec.describe "JobOrders", type: :request do
  path '/job_orders/jobs' do
    get "get all job" do
      tags 'Job Orders'
      produces 'application/json'
      security [bearer_auth: []]

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "job order authenticated"

        response '200', 'Returns all job orders' do
          schema type: :array,
                 items: {
                   '$ref' => '#/components/schemas/job_order_job'
                 }

          before do
            create(:job_orders__job)
            create(:job_orders__job)
          end

          before do
            expect(JobOrders::JobOrdersQuery)
              .to receive(:all_jobs)
              .and_call_original
          end

          run_test!
        end
      end
    end
  end
end
