module JobOrders
  module Projectors
    class JobOrderStatus < Projector
      projection_stream Streams::JobOrder

      class Projection
        extend Record

        schema do
          order_count Either(Integer, nil)
          criteria_met? Bool()
          candidates Hash
          not_filled? Bool()
        end

        def status
          return ClosedStatus::NOT_FILLED if not_filled?
          return ActivatedStatus::NEEDS_ORDER_COUNT if order_count.nil?
          return ActivatedStatus::NEEDS_CRITERIA unless criteria_met?
          return ClosedStatus::FILLED if hired_candidates.length >= order_count
          return StalledStatus::WAITING_ON_EMPLOYER if recommended_candidates.length + hired_candidates.length >= order_count
          return ActivatedStatus::CANDIDATES_SCREENED if screened_candidates.length.positive?

          ActivatedStatus::OPEN
        end

        private

        def hired_candidates
          candidates.select { |_, status| status == :hired }
        end

        def screened_candidates
          candidates.select { |_, status| status == :screened }
        end

        def recommended_candidates
          candidates.select { |_, status| status == :recommended }
        end

        def rescinded_candidates
          candidates.select { |_, status| status == :rescinded }
        end
      end

      def init
        Projection.new(
          order_count: nil,
          criteria_met?: false,
          candidates: {},
          not_filled?: false
        )
      end

      on_message Events::OrderCountAdded::V1 do |message, accumulator|
        accumulator.with(order_count: message.data.order_count)
      end

      on_message Events::NotFilled::V1 do |_, accumulator|
        accumulator.with(not_filled?: true)
      end

      on_message Events::Activated::V1 do |_, accumulator|
        accumulator.with(not_filled?: false)
      end

      on_message Events::CriteriaAdded::V1 do |_, accumulator|
        accumulator.with(criteria_met?: true)
      end

      on_message Events::CandidateAdded::V3 do |message, accumulator|
        accumulator.candidates[message.data.person_id] = :added
        accumulator
      end

      on_message Events::CandidateRecommended::V2 do |message, accumulator|
        accumulator.candidates[message.data.person_id] = :recommended
        accumulator
      end

      on_message Events::CandidateScreened::V1 do |message, accumulator|
        accumulator.candidates[message.data.person_id] = :screened
        accumulator
      end

      on_message Events::CandidateHired::V2 do |message, accumulator|
        accumulator.candidates[message.data.person_id] = :hired
        accumulator
      end

      on_message Events::CandidateRescinded::V2 do |message, accumulator|
        accumulator.candidates[message.data.person_id] = :rescinded
        accumulator
      end
    end
  end
end
