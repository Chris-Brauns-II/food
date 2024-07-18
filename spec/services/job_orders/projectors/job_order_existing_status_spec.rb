require 'rails_helper'

RSpec.describe JobOrders::Projectors::JobOrderExistingStatus do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { JobOrders::Streams::JobOrder.new(job_order_id:) }
    let(:job_order_id) { SecureRandom.uuid }

    let(:now) { Time.zone.now }

    let(:job_order_activated) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::Activated::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_need_critiera) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::NeedsCriteria::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_candidates_screened) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidatesScreened::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_stalled) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::Stalled::V1,
        data: {
          status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER
        }
      )
    end
    let(:job_order_filled) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::Filled::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_not_filled) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::NotFilled::V1,
        data: Core::Nothing
      )
    end

    context "when there are no events" do
      let(:messages) { [] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT)
      end
    end

    context "when the last event was activated" do
      let(:messages) { [job_order_filled, job_order_not_filled, job_order_stalled, job_order_activated] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::OPEN)
      end
    end

    context "when the last event was need criteria" do
      let(:messages) { [job_order_stalled, job_order_filled, job_order_not_filled, job_order_need_critiera] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::NEEDS_CRITERIA)
      end
    end

    context "when the last event was stalled" do
      let(:messages) { [job_order_not_filled, job_order_filled, job_order_activated, job_order_stalled] }

      it "return the open status" do
        expect(subject.status).to eq(job_order_stalled.data.status)
      end
    end

    context "when the last event was stalled" do
      let(:messages) { [job_order_not_filled, job_order_activated, job_order_filled, job_order_candidates_screened] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::CANDIDATES_SCREENED)
      end
    end

    context "when the last event was filled" do
      let(:messages) { [job_order_activated, job_order_stalled, job_order_not_filled, job_order_filled] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ClosedStatus::FILLED)
      end
    end

    context "when the last event was filled" do
      let(:messages) { [job_order_activated, job_order_stalled, job_order_filled, job_order_not_filled] }

      it "return the open status" do
        expect(subject.status).to eq(JobOrders::ClosedStatus::NOT_FILLED)
      end
    end
  end
end
