module Teams
  module Commands
    module Add
      module Data
        class V1
          extend Core::Payload

          schema do
            name String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::Team,
        message_type: MessageTypes::ADD,
        version: 1
      )
    end
  end
end
