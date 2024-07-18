module Teams
  module Events
    module Added
      module Data
        class V1
          extend Core::Payload

          schema do
            name String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::Team,
        message_type: MessageTypes::ADDED,
        version: 1
      )
    end
  end
end
