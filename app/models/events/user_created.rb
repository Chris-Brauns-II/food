module Events
  module UserCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          first_name Either(String, nil), default: nil
          last_name Either(String, nil), default: nil
          email Either(String, nil), default: nil
          sub Either(String, nil), default: nil
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::User::USER_CREATED,
      version: 1
    )
  end
end
