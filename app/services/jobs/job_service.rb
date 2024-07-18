module Jobs
  class JobService
    include MessageEmitter

    def create(category:, employment_title:, employer_id:, benefits_description:, responsibilities_description:, location:, employment_type:, schedule:, work_days:, requirements_description:, trace_id:, hide_job: false, industry: []) # rubocop:disable Metrics/ParameterLists
      employer = Employer.find(employer_id)

      message_service.create!(
        schema: Events::JobCreated::V3,
        job_id: SecureRandom.uuid,
        trace_id:,
        data: {
          category:,
          employment_title:,
          employer_name: employer.name,
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
      )

      nil
    end

    def update(job_id:, category:, employment_title:, benefits_description:, responsibilities_description:, location:, employment_type:, schedule:, work_days:, requirements_description:, hide_job: false, industry: []) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        schema: Events::JobUpdated::V2,
        job_id:,
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
      )

      nil
    end
  end
end
