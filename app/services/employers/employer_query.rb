module Employers
  class EmployerQuery
    def initialize(employers:)
      @employers = employers
    end

    def all_applicants
      jobs = Job.where(employers_employer_id: employers.map(&:id))
      applicants = Applicant.where(job: jobs)
      seekers = Seeker.where(seeker_id: applicants.select(:seeker_id))

      Applicant.where(job: jobs).map do |a|
        {
          id: a.applicant_id,
          job_id: a.job.id,
          chat_enabled: true,
          certified_by: seekers.detect { |s| s.seeker_id == a.seeker_id }&.certified_by,
          created_at: a.application_submit_at,
          job_name: a.job.employment_title,
          first_name: a.first_name,
          last_name: a.last_name,
          email: a.email,
          phone_number: a.phone_number,
          profile_link: "/profiles/#{a.seeker_id}",
          programs: [], # TODO
          status: a.status,
          status_reason: a.status_reason
        }
      end
    end

    def all_jobs
      Job.where(employer: employers).map do |job|
        {
          id: job.id,
          employer_id: job.employer.employer_id,
          name: job.employment_title,
          employer_name: job.employer.name,
          description: "descriptions don't exist yet"
        }
      end
    end

    private

    attr_reader :employers
  end
end
