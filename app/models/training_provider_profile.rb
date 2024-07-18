# == Schema Information
#
# Table name: training_provider_profiles
#
#  id                   :text             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  training_provider_id :text             not null
#  user_id              :text             not null
#
# Indexes
#
#  TrainingProviderProfile_user_id_key  (user_id) UNIQUE
#
# Foreign Keys
#
#  TrainingProviderProfile_user_id_fkey  (user_id => users.id) ON DELETE => restrict ON UPDATE => cascade
#
class TrainingProviderProfile < ApplicationRecord
  belongs_to :user

  def training_provider
    TrainingProvider.find(training_provider_id)
  end

  def references
    Reference.where(author_profile_id: id)
  end
end
