module Teams
  module Commands
    module RemoveUserFromTeam
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
        message_type: MessageTypes::REMOVE_USER_FROM_TEAM,
        version: 1
      )
    end
  end
end
