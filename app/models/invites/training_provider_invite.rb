# == Schema Information
#
# Table name: invites_training_provider_invites
#
#  id                     :uuid             not null, primary key
#  email                  :string           not null
#  first_name             :string           not null
#  last_name              :string           not null
#  role_description       :string           not null
#  training_provider_name :string           not null
#  used_at                :datetime
#  training_provider_id   :uuid             not null
#
module Invites
  class TrainingProviderInvite < ApplicationRecord
  end
end
