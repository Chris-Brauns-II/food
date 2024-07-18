module Commands
  module SetContactPreference
    module Data
      class V1
        extend Core::Payload

        schema do
          preference Either(*Contact::ContactPreference::ALL)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Contact::SET_CONTACT_PREFERENCE,
      version: 1
    )
  end
end
