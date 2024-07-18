module Events
  module BasicInfoAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          first_name String
          last_name String
          phone_number Either(String, nil)
          email Either(String, nil)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::BASIC_INFO_ADDED,
      version: 1
    )
  end
end
