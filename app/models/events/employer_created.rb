module Events
  module EmployerCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          name String
          location String
          bio String
          logo_url String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Employer,
      message_type: MessageTypes::Employers::EMPLOYER_CREATED,
      version: 1
    )
  end
end
