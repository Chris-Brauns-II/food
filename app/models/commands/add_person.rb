module Commands
  module AddPerson
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id Either(String, nil)
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

      class V2
        extend Core::Payload

        schema do
          user_id Either(String, nil)
          first_name String
          last_name String
          email Either(String, nil)
          phone_number Either(String, nil)
          date_of_birth Either(Date, nil), coerce: Core::DateCoercer
          source_kind Either(*People::SourceKind::ALL, nil)
          source_identifier Either(String, nil)
        end

        def initialize(attributes)
          super
          raise ArgumentError unless email.present? || phone_number.present?
          raise ArgumentError if source_identifier.present? && source_kind.blank?
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::ADD_PERSON,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::ADD_PERSON,
      version: 2
    )
  end
end
