# frozen_string_literal: true

module Screeners
  module MessageTypes
    EVENTS = [
      SCREENER_QUESTIONS_CREATED = 'screener_questions_created',
      SCREENER_QUESTIONS_UPDATED = 'screener_questions_updated',
      SCREENER_ANSWERS_CREATED = 'screener_answers_created',
      SCREENER_ANSWERS_UPDATED = 'screener_answers_updated'
    ].freeze

    COMMANDS = [
      CREATE_SCREENER_QUESTIONS = "create_screener_questions",
      UPDATE_SCREENER_QUESTIONS = 'update_screener_questions',
      CREATE_SCREENER_ANSWERS = 'create_screener_answers',
      UPDATE_SCREENER_ANSWERS = 'update_screener_answers'
    ].freeze
  end
end
