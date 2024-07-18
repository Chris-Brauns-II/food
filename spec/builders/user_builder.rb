module Builders
  class UserBuilder
    def initialize(message_service)
      @message_service = message_service
    end

    def build( # rubocop:disable Metrics/ParameterLists
      id: SecureRandom.uuid,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.phone_number,
      roles: [],
      sub: Faker::Internet.uuid,
      person_id: nil
    )
      user = User.create!(
        id:,
        first_name:,
        last_name:,
        email:,
        phone_number:,
        sub:,
        person_id:
      )

      message_service.create!(
        user_id: id,
        schema: Events::UserCreated::V1,
        data: {
          first_name:,
          last_name:,
          email:,
          sub:
        }
      )

      roles.each do |role|
        message_service.create!(
          user_id: id,
          schema: Events::RoleAdded::V2,
          data: {
            role:
          }
        )
      end

      user
    end

    def build_as_recruiter(
      employer_id:,
      employer_name:,
      **
    )
      user = build(**)

      invite_id = SecureRandom.uuid
      message_service.create!(
        invite_id:,
        schema: Events::EmployerInviteCreated::V1,
        data: {
          invite_email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          employer_id:,
          employer_name:
        }
      )

      message_service.create!(
        invite_id:,
        schema: Events::EmployerInviteAccepted::V2,
        data: {
          user_id: user.id,
          invite_email: user.email,
          employer_id:,
          employer_name:
        }
      )

      user
    end

    def build_as_trainer(
      training_provider_id:,
      training_provider_name:,
      role_description: Faker::Company.profession,
      training_provider_profile_id: SecureRandom.uuid,
      **
    )
      user = build(**)

      invite_id = SecureRandom.uuid
      message_service.create!(
        invite_id:,
        schema: Events::TrainingProviderInviteCreated::V1,
        data: {
          invite_email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          role_description:,
          training_provider_id:,
          training_provider_name:
        }
      )

      message_service.create!(
        invite_id:,
        schema: Events::TrainingProviderInviteAccepted::V2,
        data: {
          user_id: user.id,
          invite_email: user.email,
          training_provider_profile_id:,
          training_provider_id:,
          training_provider_name:
        }
      )

      user
    end

    private

    attr_reader :message_service
  end
end
