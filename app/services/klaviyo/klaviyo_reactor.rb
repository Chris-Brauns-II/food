module Klaviyo
  class KlaviyoReactor < MessageReactor
    def can_replay?
      true
    end

    UnableToRetrieveEmailError = Class.new(StandardError)

    def initialize(client: Klaviyo::Gateway.build, **params)
      super(**params)
      @client = client
    end

    on_message Events::UserCreated::V1 do |message|
      dedup_messages(message) do
        client.user_signup(
          email: message.data.email,
          event_id: message.id,
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::PersonAdded::V1 do |message|
      email = email_for_person_stream(message.stream)
      return if email.blank?

      dedup_messages(message) do
        client.person_added(
          email:,
          occurred_at: message.occurred_at,
          event_id: message.id,
          profile_attributes: {
            first_name: message.data.first_name,
            last_name: message.data.last_name,
            phone_number: message.data.phone_number && E164.normalize(message.data.phone_number)
          },
          profile_properties: {
            date_of_birth: message.data.date_of_birth
          }
        )
      end
    end

    on_message Events::BasicInfoAdded::V1 do |message|
      email = email_for_person_stream(message.stream)
      return if email.blank?

      dedup_messages(message) do
        client.user_updated(
          email:,
          event_id: message.id,
          occurred_at: message.occurred_at,
          profile_properties: {},
          profile_attributes: {
            first_name: message.data.first_name,
            last_name: message.data.last_name,
            phone_number: message.data.phone_number && E164.normalize(message.data.phone_number)
          }
        )
      end
    end

    on_message Events::EducationExperienceAdded::V2 do |message|
      email = email_for_person_stream(message.stream)
      return if email.blank?

      dedup_messages(message) do
        client.education_experience_entered(
          email:,
          event_id: message.id,
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::EmployerInviteAccepted::V2 do |message|
      dedup_messages(message) do
        client.employer_invite_accepted(
          event_id: message.id,
          email: message.data.invite_email,
          profile_properties: {
            is_recruiter: true,
            employer_name: message.data.employer_name,
            employer_id: message.data.employer_id
          },
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::TrainingProviderInviteAccepted::V2 do |message|
      dedup_messages(message) do
        client.training_provider_invite_accepted(
          event_id: message.id,
          email: message.data.invite_email,
          profile_properties: {
            is_training_provider: true,
            training_provider_name: message.data.training_provider_name,
            training_provider_id: message.data.training_provider_id
          },
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::ExperienceAdded::V2 do |message|
      email = email_for_person_stream(message.stream)
      return if email.blank?

      dedup_messages(message) do
        client.experience_entered(
          email:,
          event_id: message.id,
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::OnboardingCompleted::V3 do |message|
      email = email_for_person_stream(message.stream)
      return if email.blank?

      dedup_messages(message) do
        client.onboarding_complete(
          email:,
          event_id: message.id,
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::ApplicantStatusUpdated::V6 do |message|
      dedup_messages(message) do
        client.application_status_updated(
          application_id: message.stream.id,
          email: message.data.applicant_email,
          employment_title: message.data.employment_title,
          employer_name: message.data.employer_name,
          event_id: message.id,
          occurred_at: message.occurred_at,
          status: message.data.status
        )
      end
    end

    on_message Events::ChatMessageSent::V2 do |message|
      dedup_messages(message) do
        applicant_status_updated = Projectors::Streams::GetFirst.project(
          stream: Streams::Application.new(application_id: message.stream.id),
          schema: Events::ApplicantStatusUpdated::V6
        )

        return if applicant_status_updated.blank?
        return if applicant_status_updated.data.user_id == message.data.from_user_id

        client.chat_message_received(
          applicant_id: message.stream.id,
          email: applicant_status_updated.data.applicant_email,
          employment_title: applicant_status_updated.data.employment_title,
          employer_name: applicant_status_updated.data.employer_name,
          event_id: message.id,
          occurred_at: message.occurred_at
        )
      end
    end

    on_message Events::JobSaved::V1 do |message|
      dedup_messages(message) do
        client.job_saved(
          email: email_for_user_stream(message.stream),
          event_id: message.id,
          event_properties: {
            job_id: message.data.job_id,
            employment_title: message.data.employment_title,
            employer_name: message.data.employer_name
          },
          occurred_at: message.occurred_at
        )
      end
    end

    private

    def dedup_messages(message)
      stream = Streams::Message.new(message_id: message.id)

      return if Projectors::Streams::HasOccurred.project(stream:, schema: Events::KlaviyoEventPushed::V1)

      yield

      message_service.create!(
        schema: Events::KlaviyoEventPushed::V1,
        trace_id: message.trace_id,
        event_id: message.id,
        data: Core::Nothing
      )
    end

    def email_for_person_stream(stream)
      messages = MessageService.stream_events(stream)
      result = People::Projectors::Email.new.project(messages)

      result.initial_email
    end

    def email_for_user_stream(stream)
      user_created = Projectors::Streams::GetFirst.project(
        stream:,
        schema: Events::UserCreated::V1
      )

      raise UnableToRetrieveEmailError if user_created.nil?

      user_created.data.email
    end

    attr_reader :client
  end
end
