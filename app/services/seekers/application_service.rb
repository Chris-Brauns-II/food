module Seekers
  class ApplicationService
    def self.apply(seeker:, job:, message_service:)
      stream = Streams::Person.new(person_id: seeker.id)
      messages = MessageService.stream_events(stream)

      most_recent_applicaiton = Projectors::MostRecentApplication.new.project(messages).applied_at(job.id)

      return if most_recent_applicaiton.present?

      message_service.create!(
        stream:,
        schema: Events::PersonApplied::V1,
        data: {
          application_id: SecureRandom.uuid,
          seeker_first_name: seeker.first_name,
          seeker_last_name: seeker.last_name,
          seeker_email: seeker.email,
          seeker_phone_number: seeker.phone_number,
          user_id: seeker.user_id,
          job_id: job.id,
          employer_name: job.employer.name,
          employment_title: job.employment_title
        }
      )
    end
  end
end
