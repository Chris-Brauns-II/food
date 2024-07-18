module Commands
  module SendEmailMessage
    module Data
      class V1
        extend Core::Payload

        schema do
          recepent_email String
          title String
          body String
          url Either(String, nil)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_EMAIL_MESSAGE,
      version: 1
    )
  end
end
