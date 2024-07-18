module Users
  class UsersAggregator < MessageConsumer
    def reset_for_replay
      UserRole.delete_all
      Recruiter.delete_all
      TrainingProviderProfile.delete_all
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      user = User.find(message.data.user_id)

      user.update!(person_id: message.stream.id)
    end

    on_message Events::RoleAdded::V2 do |message|
      user = User.find(message.stream.id)

      return if user.role?(message.data.role)

      UserRole.create!(
        role: message.data.role,
        user:
      )
    end

    on_message Events::TrainingProviderInviteAccepted::V2 do |message|
      TrainingProviderProfile.create!(
        id: message.data.training_provider_profile_id,
        user_id: message.data.user_id,
        training_provider_id: message.data.training_provider_id
      )
    end

    on_message Events::EmployerInviteAccepted::V2 do |message|
      Recruiter.create!(
        id: SecureRandom.uuid,
        user_id: message.data.user_id,
        employer_id: message.data.employer_id
      )
    end
  end
end
