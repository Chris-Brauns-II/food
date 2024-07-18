module Events
  module DateOfBirthAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          date_of_birth Date, coerce: Core::DateCoercer
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::DATE_OF_BIRTH_ADDED,
      version: 1
    )
  end
end
