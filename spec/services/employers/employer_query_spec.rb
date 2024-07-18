require 'rails_helper'

RSpec.describe Employers::EmployerQuery do
  describe "#all_applicants" do
    subject { described_class.new(employers: [employer]).all_applicants }

    let(:employer) do
      create(
        :employers_employer,
        name: "Employer"
      )
    end
    let!(:applicant) do
      create(
        :employers_applicant,
        job:,
        application_submit_at: Time.zone.local(2023, 2, 2),
        email: "hannah.block@skillarc.com",
        first_name: "Hannah",
        last_name: "Block",
        phone_number: "123-456-7890",
        status: Employers::Applicant::StatusTypes::NEW,
        status_as_of: Time.zone.now,
        status_reason: "reason_description"
      )
    end

    let(:job) do
      create(
        :employers_job,
        employer:,
        employment_title: "Welder"
      )
    end
    let!(:seeker) do
      create(
        :employers_seeker,
        certified_by: "chris@skillarc.com",
        seeker_id: applicant.seeker_id
      )
    end

    it "returns all applicants for the employer" do
      expect(subject).to eq(
        [
          {
            id: applicant.applicant_id,
            job_id: job.id,
            chat_enabled: true,
            created_at: Time.zone.local(2023, 2, 2),
            certified_by: "chris@skillarc.com",
            job_name: "Welder",
            first_name: "Hannah",
            last_name: "Block",
            phone_number: "123-456-7890",
            profile_link: "/profiles/#{applicant.seeker_id}",
            programs: [], # TODO
            status_reason: "reason_description",
            status: Employers::Applicant::StatusTypes::NEW,
            email: "hannah.block@skillarc.com"
          }
        ]
      )
    end
  end

  describe "#all_jobs" do
    subject { described_class.new(employers: [employer]).all_jobs }

    let(:employer) do
      create(
        :employers_employer,
        name: "Employer"
      )
    end
    let!(:job) do
      create(
        :employers_job,
        employer:,
        employment_title: "Welder"
      )
    end

    it "returns all jobs for the employer" do
      expect(subject).to eq(
        [{
          id: job.id,
          description: "descriptions don't exist yet",
          employer_id: employer.employer_id,
          name: "Welder",
          employer_name: "Employer"
        }]
      )
    end
  end
end
