module Events
  module ContactPreferenceSet
    module Data
      class V1
        extend Core::Payload

        schema do
          preference Either(*Contact::ContactPreference::ALL)
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Contact::CONTACT_PREFERENCE_SET,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Contact::CONTACT_PREFERENCE_SET,
      version: 2
    )
  end
end
