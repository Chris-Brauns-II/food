module Employers
  class EmployerAggregator < MessageConsumer
    def reset_for_replay
      JobOwner.delete_all
      Applicant.delete_all
      Recruiter.delete_all
      PassReason.delete_all
      Job.delete_all
      Employer.delete_all
    end

    on_message Events::ApplicantStatusUpdated::V6, :sync do |message|
      job = Job.find_by!(job_id: message.data.job_id)
      applicant = Applicant.find_or_initialize_by(
        applicant_id: message.stream.id
      )

      application_submit_at = if message.data.status == Applicant::StatusTypes::NEW
                                message.occurred_at
                              else
                                applicant.application_submit_at
                              end

      applicant.update!(
        seeker_id: message.data.seeker_id,
        job:,
        first_name: message.data.applicant_first_name,
        last_name: message.data.applicant_last_name,
        email: message.data.applicant_email,
        phone_number: message.data.applicant_phone_number,
        status: message.data.status,
        status_as_of: message.occurred_at,
        status_reason: message.data.reasons.first&.reason_description,
        application_submit_at:
      )
    end

    on_message Events::EmployerCreated::V1 do |message|
      Employer.create!(
        employer_id: message.stream_id,
        name: message.data.name,
        location: message.data.location,
        bio: message.data.bio,
        logo_url: message.data.logo_url
      )
    end

    on_message Events::EmployerInviteAccepted::V2 do |message|
      employer = Employer.find_by!(employer_id: message.data.employer_id)

      Recruiter.create!(
        employer:,
        email: message.data.invite_email
      )
    end

    on_message Events::EmployerUpdated::V1 do |message|
      e = Employer.find_by!(employer_id: message.stream_id)

      e.update!(
        **message.data.serialize
      )
    end

    on_message Events::PersonCertified::V1 do |message|
      e = Seeker.find_or_initialize_by(
        seeker_id: message.stream_id
      )

      e.update!(
        certified_by: message.data.coach_email
      )
    end

    on_message Events::JobCreated::V3 do |message|
      employer = Employer.find_by!(employer_id: message.data.employer_id)

      Job.create!(
        employer:,
        job_id: message.stream_id,
        category: message.data.category,
        employment_title: message.data.employment_title,
        benefits_description: message.data.benefits_description,
        responsibilities_description: message.data.responsibilities_description,
        location: message.data.location,
        employment_type: message.data.employment_type,
        hide_job: message.data.hide_job,
        schedule: message.data.schedule,
        work_days: message.data.work_days,
        requirements_description: message.data.requirements_description,
        industry: message.data.industry
      )
    end

    on_message Events::PassReasonAdded::V1 do |message|
      PassReason.create!(
        id: message.stream.id,
        description: message.data.description
      )
    end

    on_message Events::PassReasonRemoved::V1 do |message|
      pass_reason = Employers::PassReason.find_by(id: message.stream.id)
      return if pass_reason.blank?

      pass_reason.destroy
    end

    on_message Events::JobOwnerAssigned::V1 do |message|
      job = Job.find_by!(job_id: message.data.job_id)
      recruiter = Recruiter.find_by!(email: message.data.owner_email)

      JobOwner.create!(
        job:,
        recruiter:
      )
    end

    on_message Events::JobUpdated::V2 do |message|
      job = Job.find_by!(job_id: message.stream_id)

      job.update!(
        **message.data.serialize
      )
    end
  end
end
