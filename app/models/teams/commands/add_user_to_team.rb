module Teams
  module Commands
    module AddUserToTeam
      module Data
        class V1
          extend Core::Payload

          schema do
            user_id String
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::Team,
        message_type: MessageTypes::ADD_USER_TO_TEAM,
        version: 1
      )
    end
  end
end
