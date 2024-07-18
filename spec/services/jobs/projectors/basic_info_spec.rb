require 'rails_helper'

RSpec.describe Jobs::Projectors::BasicInfo do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:messages) do
      [
        job_created,
        job_updated
      ]
    end

    let(:job_id) { SecureRandom.uuid }

    let(:job_created) do
      build(
        :message,
        schema: Events::JobCreated::V3,
        stream_id: job_id,
        data: {
          category: Job::Categories::MARKETPLACE,
          employment_title: "A title",
          employer_name: "An employer",
          employer_id: SecureRandom.uuid,
          benefits_description: "Bad benifits",
          responsibilities_description: nil,
          location: "Columbus Ohio",
          employment_type: Job::EmploymentTypes::FULLTIME,
          hide_job: false
        }
      )
    end
    let(:job_updated) do
      build(
        :message,
        schema: Events::JobUpdated::V2,
        stream_id: job_id,
        data: {
          category: Job::Categories::MARKETPLACE,
          employment_title: "Senior Plumber",
          benefits_description: "Great Benifits",
          responsibilities_description: "Massive responsiiblities",
          location: "Columbus, OH",
          employment_type: Job::EmploymentTypes::FULLTIME,
          hide_job: false,
          schedule: "3am - 1am",
          work_days: "24/8",
          requirements_description: "Got requirements",
          industry: nil
        }
      )
    end

    it "returns the basic info" do
      expect(subject.category).to eq(job_updated.data.category)
      expect(subject.employment_title).to eq(job_updated.data.employment_title)
      expect(subject.employer_name).to eq(job_created.data.employer_name)
      expect(subject.employer_id).to eq(job_created.data.employer_id)
      expect(subject.benefits_description).to eq(job_updated.data.benefits_description)
      expect(subject.responsibilities_description).to eq(job_updated.data.responsibilities_description)
      expect(subject.location).to eq(job_updated.data.location)
      expect(subject.employment_type).to eq(job_updated.data.employment_type)
      expect(subject.hide_job).to eq(job_updated.data.hide_job)
      expect(subject.schedule).to eq(job_updated.data.schedule)
      expect(subject.work_days).to eq(job_updated.data.work_days)
      expect(subject.requirements_description).to eq(job_updated.data.requirements_description)
      expect(subject.industry).to eq(job_updated.data.industry)
    end
  end
end
