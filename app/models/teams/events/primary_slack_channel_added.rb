module Teams
  module Events
    module PrimarySlackChannelAdded
      module Data
        class V1
          extend Core::Payload

          schema do
            channel(/#[a-zA-Z\-_]+/)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::Team,
        message_type: MessageTypes::PRIMARY_SLACK_CHANNEL_ADDED,
        version: 1
      )
    end
  end
end
