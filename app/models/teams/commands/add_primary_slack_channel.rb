module Teams
  module Commands
    module AddPrimarySlackChannel
      module Data
        class V1
          extend Core::Payload

          schema do
            channel(/#[a-zA-Z\-_]+/)
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::Team,
        message_type: MessageTypes::ADD_PRIMAY_SLACK_CHANNEL,
        version: 1
      )
    end
  end
end
