module Events
  module EmployerInviteAccepted
    module Data
      class V1
        extend Core::Payload

        schema do
          employer_invite_id Uuid
          invite_email String
          employer_id Uuid
          employer_name String
        end
      end

      class V2
        extend Core::Payload

        schema do
          user_id String
          invite_email String
          employer_id Uuid
          employer_name String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Employer,
      message_type: MessageTypes::Invite::EMPLOYER_INVITE_ACCEPTED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Invite,
      message_type: MessageTypes::Invite::EMPLOYER_INVITE_ACCEPTED,
      version: 2
    )
  end
end
