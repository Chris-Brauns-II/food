# == Schema Information
#
# Table name: screeners_answers
#
#  id                     :uuid             not null, primary key
#  question_responses     :jsonb            not null
#  title                  :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  person_id              :uuid             not null
#  screeners_questions_id :uuid             not null
#
# Indexes
#
#  index_screeners_answers_on_screeners_questions_id  (screeners_questions_id)
#
# Foreign Keys
#
#  fk_rails_...  (screeners_questions_id => screeners_questions.id)
#
module Screeners
  class Answers < ApplicationRecord
    self.table_name = "screeners_answers"

    belongs_to :questions, class_name: "Screeners::Questions", foreign_key: "screeners_questions_id", inverse_of: :answers

    def question_responses
      self[:question_responses].map { |qr| QuestionResponse.new(question: qr["question"], response: qr["response"]) }
    end
  end
end
