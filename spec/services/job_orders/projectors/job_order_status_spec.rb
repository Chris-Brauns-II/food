require 'rails_helper'

RSpec.describe JobOrders::Projectors::JobOrderStatus do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { JobOrders::Streams::JobOrder.new(job_order_id:) }
    let(:job_order_id) { SecureRandom.uuid }
    let(:person_id1) { SecureRandom.uuid }
    let(:person_id2) { SecureRandom.uuid }

    let(:job_order_not_filled) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::NotFilled::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_activated) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::Activated::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_criteria_met) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CriteriaAdded::V1,
        data: Core::Nothing
      )
    end
    let(:job_order_order_count_added1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::OrderCountAdded::V1,
        data: {
          order_count: 2
        }
      )
    end
    let(:job_order_order_count_added2) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::OrderCountAdded::V1,
        data: {
          order_count: 3
        }
      )
    end
    let(:job_order_candidate_added1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateAdded::V3,
        data: {
          person_id: person_id1
        },
        metadata: {
          requestor_type: Requestor::Kinds::COACH,
          requestor_id: SecureRandom.uuid,
          requestor_email: "foo@skillarc.com"
        }
      )
    end
    let(:job_order_candidate_added2) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateAdded::V3,
        data: {
          person_id: person_id2
        },
        metadata: {
          requestor_type: Requestor::Kinds::COACH,
          requestor_id: SecureRandom.uuid,
          requestor_email: "foo@skillarc.com"
        }
      )
    end

    let(:job_order_candidate_recommended1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateRecommended::V2,
        data: {
          person_id: person_id1
        }
      )
    end
    let(:job_order_candidate_recommended2) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateRecommended::V2,
        data: {
          person_id: person_id2
        }
      )
    end

    let(:job_order_candidate_screened1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateScreened::V1,
        data: {
          person_id: person_id1
        }
      )
    end
    let(:job_order_candidate_screened2) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateScreened::V1,
        data: {
          person_id: person_id2
        }
      )
    end

    let(:job_order_candidate_hired1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateHired::V2,
        data: {
          person_id: person_id1
        }
      )
    end
    let(:job_order_candidate_hired2) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateHired::V2,
        data: {
          person_id: person_id2
        }
      )
    end

    let(:job_order_candidate_rescinded1) do
      build(
        :message,
        stream:,
        schema: JobOrders::Events::CandidateRescinded::V2,
        data: {
          person_id: person_id1
        }
      )
    end

    context "when a job order closed event has occured" do
      let(:messages) { [job_order_not_filled] }

      it "reports the status as the closed status" do
        expect(subject.status).to eq(JobOrders::ClosedStatus::NOT_FILLED)
      end

      context "when it's followed by an activation" do
        let(:messages) { [job_order_not_filled, job_order_activated] }

        it "reports the status as appropriate" do
          expect(subject.status).to eq(JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT)
        end
      end
    end

    context "when a job order has not been set occured but no order count has been set" do
      let(:messages) { [job_order_candidate_added1, job_order_candidate_recommended1, job_order_candidate_hired1] }

      it "reports the status as need order count" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT)
      end
    end

    context "when a job order has had an order count but no criteria met" do
      let(:messages) { [job_order_candidate_added1, job_order_order_count_added1, job_order_candidate_hired1] }

      it "reports the status as need order count" do
        expect(subject.status).to eq(JobOrders::ActivatedStatus::NEEDS_CRITERIA)
      end
    end

    context "when a job order has been set and criteria met" do
      context "when not enough candidates have been recommended" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_recommended1
          ]
        end

        it "reports the status as open" do
          expect(subject.status).to eq(JobOrders::ActivatedStatus::OPEN)
        end
      end

      context "when there enough candidates recommended" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_recommended1,
            job_order_candidate_hired1,
            job_order_candidate_added2,
            job_order_candidate_recommended2
          ]
        end

        it "reports the status as waiting on employer" do
          expect(subject.status).to eq(JobOrders::StalledStatus::WAITING_ON_EMPLOYER)
        end
      end

      context "when enough hires have occurred" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_recommended1,
            job_order_candidate_hired1,
            job_order_candidate_added2,
            job_order_candidate_recommended2,
            job_order_candidate_hired2
          ]
        end

        it "reports the status closed filled" do
          expect(subject.status).to eq(JobOrders::ClosedStatus::FILLED)
        end
      end

      context "when a rescinded hires to be the total too low" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_recommended1,
            job_order_candidate_hired1,
            job_order_candidate_added2,
            job_order_candidate_recommended2,
            job_order_candidate_hired2,
            job_order_candidate_rescinded1
          ]
        end

        it "reports the status open" do
          expect(subject.status).to eq(JobOrders::ActivatedStatus::OPEN)
        end
      end

      context "when job order hire count is increased" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_recommended1,
            job_order_candidate_hired1,
            job_order_candidate_added2,
            job_order_candidate_recommended2,
            job_order_candidate_hired2,
            job_order_order_count_added2
          ]
        end

        it "reports the status open" do
          expect(subject.status).to eq(JobOrders::ActivatedStatus::OPEN)
        end
      end

      context "when candidates have been screened" do
        let(:messages) do
          [
            job_order_order_count_added1,
            job_order_criteria_met,
            job_order_candidate_added1,
            job_order_candidate_added2,
            job_order_candidate_screened1,
            job_order_candidate_screened2
          ]
        end

        it "reports the status as open" do
          expect(subject.status).to eq(JobOrders::ActivatedStatus::CANDIDATES_SCREENED)
        end
      end
    end
  end
end
