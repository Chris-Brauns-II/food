module Coaches
  module CoachAssignmentService
    LOOKBACK_DAYS = 14
    NoCoachesError = Class.new(StandardError)

    def self.round_robin_assignment
      # Grab the last n days of context who had
      # an assigned coach
      assigned_contexts = PersonContext
                          .where("person_captured_at > ?", Time.zone.now - LOOKBACK_DAYS.days)
                          .where.not(assigned_coach: nil)

      coaches = Coach.all

      return if coaches.count.zero?

      actual_ratios = calculate_actual_ratios(coaches, assigned_contexts)
      target_ratios = calculate_target_ratios(coaches)

      select_coach(coaches, actual_ratios, target_ratios)
    end

    class << self
      private

      def calculate_target_ratios(coaches)
        total_weight = coaches.sum(:assignment_weight)
        target_ratios = {}

        # Get the target ratio of assignments for each coach
        # Say we have 10 coaches with weight 1
        # Here we would expect each coach to be assign 0.1 in total or 10%
        coaches.each do |coach|
          target_ratios[coach.email] = coach.assignment_weight / total_weight
        end

        target_ratios
      end

      def calculate_actual_ratios(coaches, assigned_contexts)
        total_assignemnt = assigned_contexts.count
        actual_ratios = {}

        # Set all coaches to zero as a baseline
        coaches.each do |coach|
          actual_ratios[coach.email] = 0.0
        end

        # Here we accumulate the actual ratio
        assigned_contexts.each do |context|
          actual_ratios[context.assigned_coach] ||= 0.0
          actual_ratios[context.assigned_coach] += 1.0 / total_assignemnt
        end

        actual_ratios
      end

      def select_coach(coaches, actual_ratios, target_ratios)
        selected_coach = coaches.first
        max_ratio_mismatch = 0.0

        coaches.each do |coach|
          ratio_mismatch = target_ratios[coach.email] - actual_ratios[coach.email]

          # Here we are picking the coach who is under their ratio the most
          if ratio_mismatch > max_ratio_mismatch
            selected_coach = coach
            max_ratio_mismatch = ratio_mismatch
          end
        end

        selected_coach.id
      end
    end
  end
end
