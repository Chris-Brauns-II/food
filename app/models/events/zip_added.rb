module Events
  module ZipAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          zip_code Either(/^\d{5}(?:[-\s]\d{4})?$/, nil), coerce: Core::ZipCodeCoercer
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Person::ZIP_ADDED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::ZIP_ADDED,
      version: 2
    )
  end
end
