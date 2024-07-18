# == Schema Information
#
# Table name: profile_skills
#
#  id              :text             not null, primary key
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  master_skill_id :text             not null
#  seeker_id       :uuid             not null
#
# Indexes
#
#  index_profile_skills_on_seeker_id  (seeker_id)
#
# Foreign Keys
#
#  fk_rails_...  (seeker_id => seekers.id)
#
class ProfileSkill < ApplicationRecord
  belongs_to :seeker

  def master_skill
    MasterSkill.find_by(id: master_skill_id)
  end
end
