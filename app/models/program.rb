# == Schema Information
#
# Table name: programs
#
#  id                   :text             not null, primary key
#  description          :text             not null
#  name                 :text             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  training_provider_id :text             not null
#
# Foreign Keys
#
#  Program_training_provider_id_fkey  (training_provider_id => training_providers.id) ON DELETE => restrict ON UPDATE => cascade
#
class Program < ApplicationRecord
  belongs_to :training_provider

  has_many :students, class_name: 'SeekerTrainingProvider', dependent: :destroy
end
