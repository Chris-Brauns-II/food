# == Schema Information
#
# Table name: screeners_questions
#
#  id         :uuid             not null, primary key
#  questions  :jsonb            not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Screeners
  class Questions < ApplicationRecord
    self.table_name = "screeners_questions"

    has_many :answers, class_name: "Screeners::Answers", inverse_of: :questions, dependent: :delete_all
  end
end
