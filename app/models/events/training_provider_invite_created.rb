module Events
  module TrainingProviderInviteCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          invite_email String
          first_name String
          last_name String
          role_description String
          training_provider_id Uuid
          training_provider_name String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::TRAINING_PROVIDER_INVITE_CREATED,
      version: 1
    )
  end
end
