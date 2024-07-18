module Klaviyo
  class FakeGateway
    def application_status_updated(application_id:, email:, event_id:, employment_title:, employer_name:, occurred_at:, status:) # rubocop:disable Metrics/ParameterLists
    end

    def chat_message_received(email:, event_id:, occurred_at:, applicant_id:, employment_title:, employer_name:) # rubocop:disable Metrics/ParameterLists
    end

    def person_added(email:, occurred_at:, event_id:, profile_attributes:, profile_properties:); end

    def job_saved(email:, event_id:, event_properties:, occurred_at:); end

    def user_signup(email:, occurred_at:, event_id:); end

    def lead_captured(email:, occurred_at:, event_id:, profile_attributes:); end

    def user_updated(email:, occurred_at:, event_id:, profile_attributes:, profile_properties:); end

    def education_experience_entered(email:, occurred_at:, event_id:); end

    def employer_invite_accepted(email:, occurred_at:, event_id:, profile_properties:); end

    def training_provider_invite_accepted(email:, occurred_at:, event_id:, profile_properties:); end

    def experience_entered(email:, occurred_at:, event_id:); end

    def onboarding_complete(email:, occurred_at:, event_id:); end
  end
end
