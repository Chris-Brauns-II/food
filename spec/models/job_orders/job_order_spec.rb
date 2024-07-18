require 'rails_helper'

RSpec.describe JobOrders::JobOrder do
  describe ".active" do
    subject { described_class.active }

    let!(:job_order1) { create(:job_orders__job_order, status: JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT) }
    let!(:job_order2) { create(:job_orders__job_order, status: JobOrders::ActivatedStatus::NEEDS_CRITERIA) }
    let!(:job_order3) { create(:job_orders__job_order, status: JobOrders::ActivatedStatus::OPEN) }
    let!(:job_order4) { create(:job_orders__job_order, status: JobOrders::ActivatedStatus::CANDIDATES_SCREENED) }

    let!(:not_filled) { create(:job_orders__job_order, status: JobOrders::ClosedStatus::NOT_FILLED) }
    let!(:filled) { create(:job_orders__job_order, status: JobOrders::ClosedStatus::FILLED) }

    it "returns all active job orders" do
      expect(subject).to contain_exactly(job_order1, job_order2, job_order3, job_order4)
    end
  end
end
