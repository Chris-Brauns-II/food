module JobOrders
  module Events
    module CandidateAdded
      module Data
        class V1
          extend Core::Payload

          schema do
            seeker_id Uuid
          end
        end

        class V2
          extend Core::Payload

          schema do
            person_id Uuid
          end
        end
      end

      V1 = Core::Schema.inactive(
        type: Core::EVENT,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_CANDIDATE_ADDED,
        version: 1
      )
      V2 = Core::Schema.inactive(
        type: Core::EVENT,
        data: Data::V2,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_CANDIDATE_ADDED,
        version: 2
      )
      V3 = Core::Schema.active(
        type: Core::EVENT,
        data: Data::V2,
        metadata: Core::RequestorMetadata::V2,
        stream: Streams::JobOrder,
        message_type: MessageTypes::JOB_ORDER_CANDIDATE_ADDED,
        version: 3
      )
    end
  end
end
