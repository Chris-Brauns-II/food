module Events
  module PersonalExperienceCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          activity Either(String, nil), default: nil
          description Either(String, nil), default: nil
          start_date Either(String, nil), default: nil
          end_date Either(String, nil), default: nil
          profile_id Either(Uuid, nil), default: nil
          seeker_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Seekers::PERSONAL_EXPERIENCE_CREATED,
      version: 1
    )
  end
end
