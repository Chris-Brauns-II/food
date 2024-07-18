module People
  module Projectors
    class OnboardingStatus < Projector
      projection_stream Streams::Person

      class Step
        extend Record

        schema do
          needed Bool()
          provided Bool(), default: false
        end

        def done?
          if needed
            provided
          else
            true
          end
        end
      end

      class Projection
        extend Record

        schema do
          start Step
          reliability Step
          employment Step
          education Step
          training Step
          opportunities Step
          complete Step
        end

        def next_step
          return Onboarding::Steps::START unless start.done?
          return Onboarding::Steps::RELIABILITY unless reliability.done?
          return Onboarding::Steps::EMPLOYMENT unless employment.done?
          return Onboarding::Steps::TRAINING unless training.done?
          return Onboarding::Steps::EDUCATION unless education.done?
          return Onboarding::Steps::OPPORTUNITIES unless opportunities.done?
          return Onboarding::Steps::COMPLETE_LOADING unless complete.done?

          Onboarding::Steps::COMPLETE
        end

        def progress
          case next_step
          when Onboarding::Steps::START
            0
          when Onboarding::Steps::RELIABILITY
            20
          when Onboarding::Steps::EMPLOYMENT
            40
          when Onboarding::Steps::TRAINING
            50
          when Onboarding::Steps::EDUCATION
            70
          when Onboarding::Steps::OPPORTUNITIES
            90
          when Onboarding::Steps::COMPLETE_LOADING, Onboarding::Steps::COMPLETE
            100
          end
        end
      end

      def init
        Projection.new(
          start: Step.new(needed: true),
          reliability: Step.new(needed: true),
          employment: Step.new(needed: false),
          education: Step.new(needed: false),
          training: Step.new(needed: false),
          opportunities: Step.new(needed: true),
          complete: Step.new(needed: true)
        )
      end

      on_message Events::OnboardingStarted::V2 do |_, accumulator|
        set_provided(accumulator, :start)
      end

      on_message Events::ReliabilityAdded::V2 do |message, accumulator|
        accumulator = set_provided(accumulator, :reliability)
        accumulator = set_needed(accumulator, :employment) if message.data.reliabilities.include?(Reliability::JOB)
        accumulator = set_needed(accumulator, :education) if message.data.reliabilities.include?(Reliability::EDUCATION)
        accumulator = set_needed(accumulator, :training) if message.data.reliabilities.include?(Reliability::TRAINING_PROGRAM)

        accumulator
      end

      on_message Events::ExperienceAdded::V2 do |_, accumulator|
        set_provided(accumulator, :employment)
      end

      on_message Events::EducationExperienceAdded::V2 do |_, accumulator|
        set_provided(accumulator, :education)
      end

      on_message Events::PersonTrainingProviderAdded::V1 do |_, accumulator|
        set_provided(accumulator, :training)
      end

      on_message Events::ProfessionalInterestsAdded::V2 do |_, accumulator|
        set_provided(accumulator, :opportunities)
      end

      on_message Events::OnboardingCompleted::V3 do |_, accumulator|
        accumulator = set_provided(accumulator, :start)
        accumulator = set_provided(accumulator, :reliability)
        accumulator = set_provided(accumulator, :employment)
        accumulator = set_provided(accumulator, :education)
        accumulator = set_provided(accumulator, :training)
        accumulator = set_provided(accumulator, :opportunities)
        set_provided(accumulator, :complete)
      end

      private

      def set_provided(accumulator, attribute)
        accumulator.with(**{ attribute => Step.new(**accumulator.send(attribute).to_h, provided: true) })
      end

      def set_needed(accumulator, attribute)
        accumulator.with(**{ attribute => Step.new(**accumulator.send(attribute).to_h, needed: true) })
      end
    end
  end
end
