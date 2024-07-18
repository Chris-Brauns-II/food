module JobOrders
  module Projectors
    class JobOrderExistingStatus < Projector
      projection_stream Streams::JobOrder

      class Projection
        extend Record

        schema do
          status Either(*JobOrders::OrderStatus::ALL, nil)
        end
      end

      def init
        Projection.new(
          status: JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT
        )
      end

      on_message Events::Activated::V1 do |_, accumulator|
        accumulator.with(status: ActivatedStatus::OPEN)
      end

      on_message Events::NeedsCriteria::V1 do |_, accumulator|
        accumulator.with(status: ActivatedStatus::NEEDS_CRITERIA)
      end

      on_message Events::CandidatesScreened::V1 do |_, accumulator|
        accumulator.with(status: ActivatedStatus::CANDIDATES_SCREENED)
      end

      on_message Events::Filled::V1 do |_, accumulator|
        accumulator.with(status: ClosedStatus::FILLED)
      end

      on_message Events::NotFilled::V1 do |_, accumulator|
        accumulator.with(status: ClosedStatus::NOT_FILLED)
      end

      on_message Events::Stalled::V1 do |message, accumulator|
        accumulator.with(status: message.data.status)
      end
    end
  end
end
