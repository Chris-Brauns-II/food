module Events
  module UserUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          first_name Either(String, nil)
          last_name Either(String, nil)
          phone_number Either(String, nil)
          date_of_birth Either(Date, nil), default: nil, coerce: Core::DateCoercer
          email Either(String, nil), default: nil
          zip_code Either(/^\d{5}(?:[-\s]\d{4})?$/, nil), default: nil, coerce: Core::ZipCodeCoercer
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::User::USER_UPDATED,
      version: 1
    )
  end
end
