require 'rails_helper'
require 'swagger_helper'

RSpec.describe "JobOrders", type: :request do
  path '/job_orders/orders' do
    get "get all job orders" do
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
                   '$ref' => '#/components/schemas/job_order_summary'
                 }

          before do
            job_order1 = create(:job_orders__job_order)
            job_order2 = create(:job_orders__job_order)

            create(:job_orders__candidate, job_order: job_order1)
            create(:job_orders__candidate, :applied, job_order: job_order1)

            create(:job_orders__note, job_order: job_order1)
            create(:job_orders__note, job_order: job_order1)
            create(:job_orders__note, job_order: job_order2)

            create(:job_orders__candidate, :applied, job_order: job_order2)
          end

          let(:context_id) { reminder_context_id }

          before do
            expect(JobOrders::JobOrdersQuery)
              .to receive(:all_orders)
              .and_call_original
          end

          run_test!
        end
      end
    end

    post "create a new job order" do
      tags 'Job Orders'
      consumes 'application/json'
      security [bearer_auth: []]

      parameter name: :order_params, in: :body, schema: {
        type: :object,
        properties: {
          jobId: {
            type: :string,
            format: :uuid
          }
        },
        required: %w[job_id]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:order_params) do
        {
          jobId: job_id
        }
      end
      let(:job_id) { SecureRandom.uuid }

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "job order authenticated"

        before do
          create(:job_orders__job, id: job_id)

          expect_any_instance_of(MessageService)
            .to receive(:create!)
            .with(
              schema: JobOrders::Commands::Add::V1,
              job_order_id: be_a(String),
              trace_id: be_a(String),
              data: {
                job_id:
              }
            )
            .and_call_original
        end

        response '201', 'Create the job order' do
          run_test!
        end

        response '400', 'Already active job order' do
          schema type: :object,
                 properties: {
                   reason: { type: :string }
                 }

          before do
            Event.from_message!(
              build(
                :message,
                schema: JobOrders::Events::Added::V1,
                stream_id: SecureRandom.uuid,
                data: {
                  job_id:
                }
              )
            )
          end

          run_test!
        end
      end
    end
  end

  path '/job_orders/orders/{id}' do
    get "get a job order" do
      tags 'Job Orders'
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
        include_context "job order authenticated"

        response '404', 'Job Order not found' do
          let(:job_order_id) { SecureRandom.uuid }

          run_test!
        end

        response '200', 'Returns all job orders' do
          schema '$ref' => '#/components/schemas/job_order'

          let(:job_order) { create(:job_orders__job_order) }
          let!(:candidate) { create(:job_orders__candidate, :applied, job_order:) }
          let!(:note) { create(:job_orders__note, job_order:) }

          let(:id) { job_order.id }

          before do
            expect(JobOrders::JobOrdersQuery)
              .to receive(:find_order)
              .with(id)
              .and_call_original
          end

          run_test!
        end
      end
    end

    put "update a job order" do
      tags 'Job Orders'
      consumes 'application/json'
      security [bearer_auth: []]
      parameter name: 'id',
                in: :path,
                type: :string,
                format: :uuid

      parameter name: :order_params, in: :body, schema: {
        type: :object,
        properties: {
          orderOount: {
            type: :integer
          }
        },
        required: %w[order_count]
      }

      include_context "olive branch casing parameter"
      include_context "olive branch camelcasing"

      let(:id) { SecureRandom.uuid }
      let(:order_params) do
        {
          orderCount: order_count
        }
      end
      let(:order_count) { 10 }

      it_behaves_like "an unauthenticated user"

      context "when authenticated" do
        include_context "job order authenticated"

        response '404', 'Job Order not found' do
          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:add_order_count)
              .with(
                job_order_id: id,
                order_count:,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          let(:id) { SecureRandom.uuid }

          run_test!
        end

        response '202', 'Update the job order' do
          before do
            expect_any_instance_of(JobOrders::JobOrdersReactor)
              .to receive(:add_order_count)
              .with(
                job_order_id: id,
                order_count:,
                trace_id: be_a(String)
              )
              .and_call_original
          end

          let(:job_order) { create(:job_orders__job_order) }
          let(:id) { job_order.id }

          run_test!
        end
      end
    end
  end

  path '/job_orders/orders/{id}/activate' do
    post "activate a job order" do
      tags 'Job Orders'
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
        include_context "job order authenticated"

        before do
          expect_any_instance_of(MessageService)
            .to receive(:create!)
            .with(
              schema: JobOrders::Commands::Activate::V1,
              job_order_id: id,
              trace_id: be_a(String),
              data: Core::Nothing
            )
            .and_call_original

          messages.each do |message|
            Event.from_message!(message)
          end
        end

        let(:job) { create(:job_orders__job) }
        let(:id) { SecureRandom.uuid }

        let(:order_1_added) do
          build(
            :message,
            schema: JobOrders::Events::Added::V1,
            stream_id: id,
            data: {
              job_id: job.id
            },
            occurred_at: 5.minutes.ago
          )
        end
        let(:order_1_not_filled) do
          build(
            :message,
            schema: JobOrders::Events::NotFilled::V1,
            stream_id: id,
            data: Core::Nothing,
            occurred_at: 4.minutes.ago
          )
        end
        let(:order_2_added) do
          build(
            :message,
            schema: JobOrders::Events::Added::V1,
            stream_id: SecureRandom.uuid,
            data: {
              job_id: job.id
            },
            occurred_at: 3.minutes.ago
          )
        end

        response '202', 'activation accepted' do
          let(:messages) { [order_1_added, order_1_not_filled] }

          run_test!
        end

        response '400', 'Already active job order' do
          schema type: :object,
                 properties: {
                   reason: { type: :string }
                 }

          let(:messages) { [order_1_added, order_1_not_filled, order_2_added] }

          run_test!
        end
      end
    end
  end

  path '/job_orders/orders/{id}/close_not_filled' do
    post "activate a job order" do
      tags 'Job Orders'
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
        include_context "job order authenticated"

        before do
          expect_any_instance_of(JobOrders::JobOrdersReactor)
            .to receive(:close_job_order_not_filled)
            .with(
              job_order_id: id,
              trace_id: be_a(String)
            )
            .and_call_original
        end

        response '404', 'Job Order not found' do
          let(:id) { SecureRandom.uuid }

          run_test!
        end

        response '202', 'close not filled accepted' do
          let(:job_order) { create(:job_orders__job_order) }
          let(:id) { job_order.id }

          run_test!
        end
      end
    end
  end
end
