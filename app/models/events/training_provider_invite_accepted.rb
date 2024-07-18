module Events
  module TrainingProviderInviteAccepted
    module Data
      class V1
        extend Core::Payload

        schema do
          training_provider_invite_id Either(Uuid, nil), default: nil
          invite_email String
          training_provider_id Uuid
          training_provider_name String
        end
      end

      class V2
        extend Core::Payload

        schema do
          training_provider_profile_id Uuid
          user_id String
          invite_email String
          training_provider_id Uuid
          training_provider_name String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::TrainingProvider,
      message_type: MessageTypes::Invite::TRAINING_PROVIDER_INVITE_ACCEPTED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::TRAINING_PROVIDER_INVITE_ACCEPTED,
      version: 2
    )
  end
end
