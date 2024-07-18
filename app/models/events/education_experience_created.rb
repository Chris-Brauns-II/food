module Events
  module EducationExperienceCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          organization_name Either(String, nil), default: nil
          title Either(String, nil), default: nil
          activities Either(String, nil), default: nil
          graduation_date Either(String, nil), default: nil
          gpa Either(String, nil), default: nil
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
      message_type: MessageTypes::Seekers::EDUCATION_EXPERIENCE_CREATED,
      version: 1
    )
  end
end
