module People
  class PersonEventEmitter
    def initialize(message_service:)
      @message_service = message_service
    end

    def add_education_experience(person_id:, organization_name:, title:, graduation_date:, gpa:, activities:, trace_id:, id: SecureRandom.uuid) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        schema: Events::EducationExperienceAdded::V2,
        person_id:,
        trace_id:,
        data: {
          id:,
          organization_name:,
          title:,
          graduation_date:,
          gpa:,
          activities:
        }
      )
    end

    def remove_education_experience(person_id:, education_experience_id:, trace_id:)
      message_service.create!(
        schema: Events::EducationExperienceDeleted::V2,
        trace_id:,
        person_id:,
        data: {
          id: education_experience_id
        }
      )
    end

    def add_personal_experience(person_id:, activity:, description:, start_date:, end_date:, trace_id:, id: SecureRandom.uuid) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        schema: Events::PersonalExperienceAdded::V2,
        person_id:,
        trace_id:,
        data: {
          id:,
          activity:,
          description:,
          start_date:,
          end_date:
        }
      )
    end

    def remove_personal_experience(person_id:, personal_experience_id:, trace_id:)
      message_service.create!(
        schema: Events::PersonalExperienceRemoved::V2,
        trace_id:,
        person_id:,
        data: {
          id: personal_experience_id
        }
      )
    end

    def add_experience(person_id:, organization_name:, position:, start_date:, end_date:, is_current:, description:, trace_id:, id: SecureRandom.uuid) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        schema: Events::ExperienceAdded::V2,
        trace_id:,
        person_id:,
        data: {
          id:,
          organization_name:,
          position:,
          start_date:,
          end_date:,
          description:,
          is_current:
        }
      )
    end

    def remove_experience(person_id:, experience_id:, trace_id:)
      message_service.create!(
        schema: Events::ExperienceRemoved::V2,
        trace_id:,
        person_id:,
        data: {
          id: experience_id
        }
      )
    end

    def add_person_training_provider(person_id:, trace_id:, program_id:, training_provider_id:, status:, id: SecureRandom.uuid) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        person_id:,
        trace_id:,
        schema: Events::PersonTrainingProviderAdded::V1,
        data: {
          id:,
          status:,
          program_id:,
          training_provider_id:
        }
      )
    end

    def add_reliability(person_id:, trace_id:, reliabilities:)
      message_service.create!(
        person_id:,
        trace_id:,
        schema: Events::ReliabilityAdded::V2,
        data: {
          reliabilities:
        }
      )
    end

    def add_professional_interests(person_id:, trace_id:, interests:)
      message_service.create!(
        person_id:,
        trace_id:,
        schema: Events::ProfessionalInterestsAdded::V2,
        data: {
          interests:
        }
      )
    end

    def complete_onboarding(person_id:, trace_id:)
      message_service.create!(
        person_id:,
        trace_id:,
        schema: Commands::CompleteOnboarding::V2,
        data: Core::Nothing
      )
    end

    private

    attr_reader :message_service
  end
end
