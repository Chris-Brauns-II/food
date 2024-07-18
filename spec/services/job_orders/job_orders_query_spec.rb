require 'rails_helper'

RSpec.describe JobOrders::JobOrdersQuery do
  describe ".all_orders" do
    subject { described_class.all_orders }

    let!(:job1) { create(:job_orders__job, applicable_for_job_orders: true) }
    let!(:job2) { create(:job_orders__job, applicable_for_job_orders: false) }
    let!(:job_order1) { create(:job_orders__job_order, job: job1, team_id: SecureRandom.uuid) }
    let!(:job_order2) { create(:job_orders__job_order, job: job2) }

    it "returns all orders which have applicable jobs" do
      expected_response = [
        {
          id: job_order1.id,
          job_id: job1.id,
          employment_title: job1.employment_title,
          employer_name: job1.employer_name,
          opened_at: job_order1.opened_at,
          closed_at: job_order1.closed_at,
          order_count: job_order1.order_count,
          hire_count: job_order1.hire_count,
          recommended_count: job_order1.recommended_count,
          status: job_order1.status,
          team_id: job_order1.team_id
        }
      ]

      expect(subject).to eq(expected_response)
    end
  end

  describe ".all_active_orders" do
    subject { described_class.all_active_orders }

    let!(:job1) { create(:job_orders__job, applicable_for_job_orders: true) }
    let!(:job2) { create(:job_orders__job, applicable_for_job_orders: false) }
    let!(:job_order1) { create(:job_orders__job_order, job: job1) }
    let!(:job_order2) { create(:job_orders__job_order, job: job2, status: JobOrders::ClosedStatus::NOT_FILLED) }

    it "returns all open orders which have applicable jobs" do
      expected_response = [
        {
          id: job_order1.id,
          job_id: job1.id,
          employment_title: job1.employment_title,
          employer_name: job1.employer_name,
          opened_at: job_order1.opened_at,
          closed_at: job_order1.closed_at,
          order_count: job_order1.order_count,
          hire_count: job_order1.hire_count,
          recommended_count: job_order1.recommended_count,
          status: job_order1.status,
          team_id: job_order1.team_id
        }
      ]

      expect(subject).to eq(expected_response)
    end
  end

  describe ".all_jobs" do
    subject { described_class.all_jobs }

    let!(:job1) { create(:job_orders__job, applicable_for_job_orders: true) }
    let!(:job2) { create(:job_orders__job, applicable_for_job_orders: false) }

    it "returns all orders which have applicable jobs" do
      expected_response = [
        {
          id: job1.id,
          employer_name: job1.employer_name,
          employer_id: job1.employer_id,
          employment_title: job1.employment_title
        }
      ]

      expect(subject).to eq(expected_response)
    end
  end

  describe ".find_order" do
    subject { described_class.find_order(id) }

    let(:job) { create(:job_orders__job, applicable_for_job_orders: true) }
    let(:job_order) { create(:job_orders__job_order, job:) }
    let(:id) { job_order.id }

    let!(:candidate1) { create(:job_orders__candidate, job_order:) }

    it "returns the order with the given id" do
      expected_response = {
        id: job_order.id,
        job_id: job.id,
        employment_title: job.employment_title,
        employer_name: job.employer_name,
        benefits_description: job.benefits_description,
        requirements_description: job.requirements_description,
        responsibilities_description: job.responsibilities_description,
        opened_at: job_order.opened_at,
        closed_at: job_order.closed_at,
        order_count: job_order.order_count,
        hire_count: job_order.hire_count,
        team_id: job_order.team_id,
        recommended_count: job_order.recommended_count,
        status: job_order.status,
        candidates: [
          {
            id: candidate1.id,
            first_name: candidate1.person.first_name,
            last_name: candidate1.person.last_name,
            phone_number: candidate1.person.phone_number,
            email: candidate1.person.email,
            applied_at: candidate1.applied_at,
            recommended_at: candidate1.recommended_at,
            recommended_by: candidate1.recommended_by,
            status: candidate1.status,
            person_id: candidate1.person_id
          }
        ],
        notes: []
      }

      expect(subject).to eq(expected_response)
    end
  end
end
