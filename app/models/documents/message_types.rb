# frozen_string_literal: true

module Documents
  module MessageTypes
    EVENTS = [
      RESUME_GENERATED = "resume_generated",
      RESUME_GENERATION_FAILED = "resume_generation_failed",
      RESUME_GENERATION_REQUESTED = "resume_generation_requested",
      SCREENER_GENERATED = "screener_generated",
      SCREENER_GENERATION_FAILED = "screener_generation_failed",
      SCREENER_GENERATION_REQUESTED = "screener_generation_requested"
    ].freeze

    COMMANDS = [
      GENERATE_SCREENER = "generate_screener",
      GENERATE_SCREENER_FOR_ANSWERS = "generate_screener_for_answers",
      GENERATE_RESUME = "generate_resume",
      GENERATE_RESUME_FOR_PERSON = "generate_resume_for_person"
    ].freeze
  end
end
