require 'rails_helper'

RSpec.describe Employers::Employer do
  describe ".active?" do
    subject { employer.active? }

    let(:employer) { create(:employers_employer) }
    let!(:job) { create(:employers_job, employer:, hide_job:) }

    context "when the employer has an active job" do
      let(:hide_job) { false }

      it { is_expected.to be true }
    end

    context "when the employer has no active jobs" do
      let(:hide_job) { true }

      it { is_expected.to be false }
    end
  end

  describe ".applicants" do
    let(:employer) { create(:employers_employer) }

    let(:job1) { create(:employers_job, employer:) }
    let(:job2) { create(:employers_job, employer:) }

    let!(:applicant1) { create(:employers_applicant, job: job1) }
    let!(:applicant2) { create(:employers_applicant, job: job2) }
    let!(:applicant3) { create(:employers_applicant) }

    it "returns all applicants for the employer" do
      expect(employer.applicants).to match_array([applicant1, applicant2])
    end
  end
end
