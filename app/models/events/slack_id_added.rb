module Events
  module SlackIdAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          slack_id String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Contact::SLACK_ID_ADDED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Contact::SLACK_ID_ADDED,
      version: 2
    )
  end
end
