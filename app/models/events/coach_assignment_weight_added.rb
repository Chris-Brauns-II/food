module Events
  module CoachAssignmentWeightAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          weight 0.0..
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coach,
      message_type: MessageTypes::Coaches::COACH_ASSIGNMENT_WEIGHT_ADDED,
      version: 1
    )
  end
end
