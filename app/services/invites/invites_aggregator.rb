module Invites
  class InvitesAggregator < MessageConsumer
    def reset_for_replay
      EmployerInvite.delete_all
      TrainingProviderInvite.delete_all
    end

    on_message Events::EmployerInviteCreated::V1 do |message|
      EmployerInvite.create!(
        id: message.stream.id,
        email: message.data.invite_email,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        employer_id: message.data.employer_id,
        employer_name: message.data.employer_name
      )
    end

    on_message Events::EmployerInviteAccepted::V2 do |message|
      EmployerInvite.update!(
        message.stream.id,
        used_at: message.occurred_at
      )
    end

    on_message Events::TrainingProviderInviteCreated::V1 do |message|
      TrainingProviderInvite.create!(
        id: message.stream.id,
        email: message.data.invite_email,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        training_provider_id: message.data.training_provider_id,
        training_provider_name: message.data.training_provider_name,
        role_description: message.data.role_description
      )
    end

    on_message Events::TrainingProviderInviteAccepted::V2 do |message|
      TrainingProviderInvite.update!(
        message.stream.id,
        used_at: message.occurred_at
      )
    end
  end
end
