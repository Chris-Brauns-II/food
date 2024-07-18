module Commands
  module NotifyEmployerOfApplicant
    module Data
      class V1
        extend Core::Payload

        schema do
          employment_title String
          recepent_email String

          certified_by Either(String, nil), default: nil
          applicant_first_name String
          applicant_last_name String
          applicant_seeker_id Uuid
          applicant_email String
          applicant_phone_number Either(String, nil), default: nil
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Application,
      message_type: MessageTypes::Contact::NOTIFY_EMPLOYER_OF_APPLICANT,
      version: 1
    )
  end
end
