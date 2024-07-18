# == Schema Information
#
# Table name: training_providers
#
#  id          :text             not null, primary key
#  name        :text             not null
#  description :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TrainingProvider < ApplicationRecord
  has_many :programs, dependent: :destroy
end
