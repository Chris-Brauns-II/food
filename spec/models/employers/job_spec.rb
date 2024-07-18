require 'rails_helper'

RSpec.describe Employers::Job, type: :model do
  describe ".active" do
    subject { described_class.active }

    let!(:active_job) { create(:employers_job, hide_job: false) }
    let!(:inactive_job) { create(:employers_job, hide_job: true) }

    it "returns active jobs" do
      expect(subject).to eq([active_job])
    end
  end

  describe "#owner_emails" do
    subject { job.owner_emails }

    let(:job) { create(:employers_job) }

    context "when there is no job owner" do
      context "when there is a recruiter" do
        let!(:recruiter) { create(:employers_recruiter, employer: job.employer) }

        it "returns the first recruiter's email" do
          expect(subject).to eq([recruiter.email])
        end
      end

      context "when there is no recruiter" do
        it "returns chris@skillarc.com" do
          expect(subject).to eq(["chris@skillarc.com"])
        end
      end
    end

    context "when there is a job owner" do
      let!(:job_owner) { create(:employers_job_owner, job:, recruiter: other_recruiter) }
      let(:other_recruiter) { create(:employers_recruiter, employer: job.employer) }

      it "returns the job owner's email" do
        expect(subject).to eq([other_recruiter.email])
      end
    end
  end
end
