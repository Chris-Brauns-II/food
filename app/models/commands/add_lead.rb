module Commands
  module AddLead
    module Data
      class V1
        extend Core::Payload

        schema do
          email Either(String, nil), default: nil
          lead_id Uuid
          phone_number String
          first_name String
          last_name String
          lead_captured_by String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::ADD_LEAD,
      version: 1
    )
  end
end
