module Events
  module EmployerInviteCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          invite_email String
          first_name String
          last_name String
          employer_id Uuid
          employer_name String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::EMPLOYER_INVITE_CREATED,
      version: 1
    )
  end
end
