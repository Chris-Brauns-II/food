module Commands
  module UpdateEmployer
    module Data
      class V1
        extend Core::Payload

        schema do
          name Either(String, nil)
          location Either(String, nil)
          bio Either(String, nil)
          logo_url Either(String, nil)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Employer,
      message_type: MessageTypes::Employers::UPDATE_EMPLOYER,
      version: 1
    )
  end
end
