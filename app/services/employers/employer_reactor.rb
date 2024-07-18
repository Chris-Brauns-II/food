module Employers
  class EmployerReactor < MessageReactor
    on_message Events::ApplicantStatusUpdated::V6 do |message|
      return unless message.data.status == Applicant::StatusTypes::NEW

      job = Job.find_by!(job_id: message.data.job_id)
      certified_by = Seeker.find_by(seeker_id: message.data.seeker_id)&.certified_by

      data = message.data

      job.owner_emails.each do |owner_email|
        message_service.create!(
          schema: Commands::NotifyEmployerOfApplicant::V1,
          application_id: message.stream.id,
          trace_id: message.trace_id,
          data: {
            employment_title: data.employment_title,
            recepent_email: owner_email,
            certified_by:,
            applicant_first_name: data.applicant_first_name,
            applicant_last_name: data.applicant_last_name,
            applicant_seeker_id: data.seeker_id,
            applicant_email: data.applicant_email,
            applicant_phone_number: data.applicant_phone_number
          }
        )
      end
    end

    on_message Events::DayElapsed::V2 do |message|
      date = message.data.date
      day_of_week = date.strftime("%A").downcase

      return unless day_of_week == Events::DayElapsed::Data::DaysOfWeek::TUESDAY

      Employer.find_each do |employer|
        next unless employer.active?

        new_applicants = employer.applicants.active.where(status_as_of: date - 1.week..).map do |applicant|
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: applicant.first_name,
            last_name: applicant.last_name,
            certified_by: Seeker.find_by(seeker_id: applicant.seeker_id)&.certified_by
          )
        end

        pending_applicants = employer.applicants.active.where(status_as_of: ...date - 1.week).map do |applicant|
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: applicant.first_name,
            last_name: applicant.last_name,
            certified_by: Seeker.find_by(seeker_id: applicant.seeker_id)&.certified_by
          )
        end

        employer.recruiters.each do |recruiter|
          message_service.create!(
            schema: Commands::SendWeeklyEmployerUpdate::V1,
            employer_id: employer.id,
            trace_id: SecureRandom.uuid,
            data: {
              employer_name: employer.name,
              recepent_email: recruiter.email,
              new_applicants:,
              pending_applicants:
            }
          )
        end
      end
    end
  end
end
