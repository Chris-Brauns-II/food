module Builders
  class PersonBuilder
    def initialize(message_service)
      @message_service = message_service
    end

    def build( # rubocop:disable Metrics/ParameterLists
      id: SecureRandom.uuid,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.phone_number,
      date_of_birth: "10/09/1990",
      **
    )
      user_id = SecureRandom.uuid
      user = UserBuilder.new(message_service).build(id: user_id, first_name:, last_name:, email:, phone_number:, person_id: id, **)

      message_service.create!(
        person_id: id,
        schema: Events::PersonAdded::V1,
        data: {
          first_name:,
          last_name:,
          email:,
          phone_number:,
          date_of_birth:
        }
      )
      message_service.create!(
        person_id: id,
        schema: Events::PersonAssociatedToUser::V1,
        data: {
          user_id:
        }
      )

      message_service.create!(
        person_id: id,
        schema: Events::OnboardingStarted::V2,
        data: Core::Nothing
      )
      message_service.create!(
        person_id: id,
        schema: Events::OnboardingCompleted::V3,
        data: Core::Nothing
      )

      Seeker.new(
        id:,
        user_id: user.id,
        first_name:,
        last_name:,
        email:,
        phone_number:
      )
    end

    def build_as_student(
      training_provider_id:,
      program_id:,
      status: "Enrolled",
      person_profile_id: SecureRandom.uuid,
      **
    )
      person = build(**)

      message_service.create!(
        person_id: person.id,
        schema: Events::PersonTrainingProviderAdded::V1,
        data: {
          training_provider_id:,
          program_id:,
          status:,
          id: person_profile_id
        }
      )

      person
    end

    private

    attr_reader :message_service
  end
end
