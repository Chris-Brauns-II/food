module Documents
  module Commands
    module GenerateResume
      module WorkExperience
        class V1
          extend Core::Payload

          schema do
            organization_name Either(String, nil)
            position Either(String, nil)
            start_date Either(String, nil)
            end_date Either(String, nil)
            is_current Bool()
            description Either(String, nil)
          end
        end
      end

      module EducationExperience
        class V1
          extend Core::Payload

          schema do
            organization_name Either(String, nil)
            title Either(String, nil)
            activities Either(String, nil)
            graduation_date Either(String, nil), default: nil
            gpa Either(String, nil), default: nil
          end
        end
      end

      module Data
        class V1
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            bio Either(String, nil)
            work_experiences ArrayOf(WorkExperience::V1)
            education_experiences ArrayOf(EducationExperience::V1)
            document_kind Either(*DocumentKind::ALL)
            first_name Either(String, nil)
            last_name Either(String, nil)
            page_limit 1..
          end
        end

        class V2
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            bio Either(String, nil)
            email Either(String, nil)
            phone_number Either(String, nil)
            work_experiences ArrayOf(WorkExperience::V1)
            education_experiences ArrayOf(EducationExperience::V1)
            document_kind Either(*DocumentKind::ALL)
            first_name Either(String, nil)
            last_name Either(String, nil)
            page_limit 1..
          end
        end

        class V3
          extend Core::Payload

          schema do
            person_id Uuid
            anonymized Bool()
            checks ArrayOf(Either(*Checks::ALL))
            bio Either(String, nil)
            email Either(String, nil)
            phone_number Either(String, nil)
            work_experiences ArrayOf(WorkExperience::V1)
            education_experiences ArrayOf(EducationExperience::V1)
            document_kind Either(*DocumentKind::ALL)
            first_name Either(String, nil)
            last_name Either(String, nil)
            page_limit 1..
          end
        end
      end

      V1 = Core::Schema.inactive(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::GENERATE_RESUME,
        version: 1
      )
      V2 = Core::Schema.inactive(
        type: Core::COMMAND,
        data: Data::V2,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::GENERATE_RESUME,
        version: 2
      )
      V3 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V3,
        metadata: Core::RequestorMetadata::V1,
        stream: Streams::ResumeDocument,
        message_type: MessageTypes::GENERATE_RESUME,
        version: 3
      )
    end
  end
end
