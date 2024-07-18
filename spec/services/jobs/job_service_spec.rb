require 'rails_helper'

RSpec.describe Jobs::JobService do
  describe "#create" do
    subject { described_class.new.create(**params) }

    include_context "event emitter"

    let(:params) do
      {
        trace_id: SecureRandom.uuid,
        category:,
        employment_title:,
        employer_id:,
        benefits_description:,
        responsibilities_description:,
        location:,
        employment_type:,
        hide_job:,
        schedule:,
        work_days:,
        requirements_description:,
        industry:
      }
    end
    let(:category) { Job::Categories::MARKETPLACE }
    let(:employment_title) { "Laborer" }
    let(:employer) { create(:employer) }
    let(:employer_id) { employer.id }
    let(:employer_name) { employer.name }
    let(:benefits_description) { "Benefits" }
    let(:responsibilities_description) { "Responsibilities" }
    let(:employment_title) { "Laborer" }
    let(:location) { "Columbus, OH" }
    let(:employment_type) { "FULLTIME" }
    let(:hide_job) { false }
    let(:schedule) { "9-5" }
    let(:work_days) { "M-F" }
    let(:requirements_description) { "Requirements" }
    let(:industry) { ["manufacturing"] }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::JobCreated::V3,
        job_id: be_a(String),
        trace_id: be_a(String),
        data: {
          category:,
          employment_title:,
          employer_name:,
          employer_id:,
          benefits_description:,
          responsibilities_description:,
          location:,
          employment_type:,
          hide_job:,
          schedule:,
          work_days:,
          requirements_description:,
          industry:
        }
      ).and_call_original

      subject
    end
  end

  describe "#update" do
    subject { described_class.new.update(**params) }

    include_context "event emitter"

    let(:job) { create(:job) }
    let(:params) do
      {
        job_id: job.id,
        category:,
        employment_title:,
        benefits_description:,
        responsibilities_description:,
        location:,
        employment_type:,
        hide_job:,
        schedule:,
        work_days:,
        requirements_description:,
        industry:
      }
    end
    let(:category) { Job::Categories::STAFFING }
    let(:employment_title) { "NEW Laborer" }
    let(:benefits_description) { "NEW Benefits" }
    let(:responsibilities_description) { "NEW Responsibilities" }
    let(:employment_title) { "NEW Employment Title" }
    let(:location) { "NEW Columbus, OH" }
    let(:employment_type) { Job::EmploymentTypes::PARTTIME }
    let(:hide_job) { true }
    let(:schedule) { "NEW 9-5" }
    let(:work_days) { "NEW M-F" }
    let(:requirements_description) { "NEW Requirements" }
    let(:industry) { [Job::Industries::HEALTHCARE] }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::JobUpdated::V2,
        job_id: job.id,
        data: {
          category:,
          employment_title:,
          benefits_description:,
          responsibilities_description:,
          location:,
          employment_type:,
          hide_job:,
          schedule:,
          work_days:,
          requirements_description:,
          industry:
        }
      ).and_call_original

      subject
    end
  end
end
