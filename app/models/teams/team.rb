# == Schema Information
#
# Table name: teams_teams
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Teams
  class Team < ApplicationRecord
  end
end
