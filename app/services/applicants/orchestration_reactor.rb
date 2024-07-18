module Applicants
  class OrchestrationReactor < MessageReactor
    on_message Events::PersonApplied::V1, :sync do |message|
      message_service.create!(
        application_id: message.data.application_id,
        trace_id: message.trace_id,
        schema: Events::ApplicantStatusUpdated::V6,
        data: {
          applicant_first_name: message.data.seeker_first_name,
          applicant_last_name: message.data.seeker_last_name,
          applicant_email: message.data.seeker_email,
          applicant_phone_number: message.data.seeker_phone_number,
          seeker_id: message.stream.id,
          user_id: message.data.user_id,
          job_id: message.data.job_id,
          employer_name: message.data.employer_name,
          employment_title: message.data.employment_title,
          status: ApplicantStatus::StatusTypes::NEW,
          reasons: []
        },
        metadata: {
          user_id: message.data.user_id
        }
      )
    end
  end
end
