module Commands
  module CreateEmployerInvite
    module Data
      class V1
        extend Core::Payload

        schema do
          invite_email String
          first_name String
          last_name String
          employer_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::CREATE_EMPLOYER_INVITE,
      version: 1
    )
  end
end
