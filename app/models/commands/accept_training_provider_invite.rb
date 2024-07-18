module Commands
  module AcceptTrainingProviderInvite
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::ACCEPT_TRAINING_PROVIDER_INVITE,
      version: 1
    )
  end
end
