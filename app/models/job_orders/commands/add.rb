module JobOrders
  module Commands
    module Add
      module Data
        class V1
          extend Core::Payload

          schema do
            job_id Uuid
          end
        end
      end

      V1 = Core::Schema.active(
        type: Core::COMMAND,
        data: Data::V1,
        metadata: Core::Nothing,
        stream: Streams::JobOrder,
        message_type: MessageTypes::ADD_JOB_ORDER,
        version: 1
      )
    end
  end
end
