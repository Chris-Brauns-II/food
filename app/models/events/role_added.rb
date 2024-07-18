module Events
  module RoleAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          role Either(*Role::Types::ALL)
          email String
          coach_id Either(Uuid, nil), default: nil
        end
      end

      class V2
        extend Core::Payload

        schema do
          role Either(*Role::Types::ALL)
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::User::ROLE_ADDED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::User::ROLE_ADDED,
      version: 2
    )
  end
end
