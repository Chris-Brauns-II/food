require 'rails_helper'

RSpec.describe Job do
  describe "validations" do
    context "when industry is not provided" do
      let(:employer) { create(:employer) }

      it "defaults to []" do
        job = Job.create!(
          id: SecureRandom.uuid,
          employer_id: employer.id,
          employment_title: "Laborer",
          location: "Columbus, OH",
          benefits_description: "Benefits",
          responsibilities_description: "Responsibilities",
          employment_type: "FULLTIME",
          schedule: "9-5",
          work_days: "M-F",
          requirements_description: "Requirements"
        )

        expect(job.industry).to eq([])
        expect(job).to be_valid
      end
    end

    context "when industry is provided" do
      context "and the values are not in Industries::ALL" do
        it "is invalid" do
          job = build(:job, industry: ["invalid"])

          expect(job).to be_invalid
          expect(job.errors[:industry]).to eq(["invalid is not a valid industry"])
        end
      end

      context "and the values are in Industries::ALL" do
        it "is valid" do
          job = build(:job, industry: [described_class::Industries::MANUFACTURING])

          expect(job).to be_valid
        end
      end
    end
  end
end
