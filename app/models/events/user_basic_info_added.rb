module Events
  module UserBasicInfoAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id String
          first_name String
          last_name String
          phone_number Either(String, nil)
          date_of_birth Either(Date, nil), coerce: Core::DateCoercer
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::USER_BASIC_INFO_ADDED,
      version: 1
    )
  end
end
