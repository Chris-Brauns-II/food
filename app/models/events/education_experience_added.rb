module Events
  module EducationExperienceAdded
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
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Person::EDUCATION_EXPERIENCE_ADDED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::EDUCATION_EXPERIENCE_ADDED,
      version: 2
    )
  end
end
