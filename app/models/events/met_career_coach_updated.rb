module Events
  module MetCareerCoachUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          met_career_coach Bool()
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::MET_CAREER_COACH_UPDATED,
      version: 1
    )
  end
end
