# == Schema Information
#
# Table name: seeker_training_providers
#
#  id                   :uuid             not null, primary key
#  status               :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  program_id           :uuid
#  seeker_id            :uuid             not null
#  training_provider_id :uuid             not null
#
# Indexes
#
#  index_seeker_training_providers_on_program_id            (program_id)
#  index_seeker_training_providers_on_seeker_id             (seeker_id)
#  index_seeker_training_providers_on_training_provider_id  (training_provider_id)
#
class SeekerTrainingProvider < ApplicationRecord
  belongs_to :training_provider
  belongs_to :program, optional: true

  def seeker
    Seeker.find(seeker_id)
  end
end
