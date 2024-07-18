module Events
  module PersonAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          first_name String
          last_name String
          email Either(String, nil)
          phone_number Either(String, nil)
          date_of_birth Either(Date, nil), coerce: Core::DateCoercer
        end

        def initialize(attributes)
          super
          raise ArgumentError unless email.present? || phone_number.present?
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_ADDED,
      version: 1
    )
  end
end
