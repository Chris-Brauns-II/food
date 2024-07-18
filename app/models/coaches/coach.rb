# == Schema Information
#
# Table name: coaches_coaches
#
#  id                :uuid             not null, primary key
#  assignment_weight :float            not null
#  email             :string
#  user_id           :string           not null
#
# Indexes
#
#  index_coaches_coaches_on_user_id  (user_id)
#
module Coaches
  class Coach < ApplicationRecord
    has_many :reminders, class_name: "Coaches::Reminder", dependent: :destroy, inverse_of: :coach
    has_many :job_recommendations, class_name: "Coaches::PersonJobRecommendation", dependent: :destroy, inverse_of: :coach
  end
end
