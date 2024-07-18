# == Schema Information
#
# Table name: desired_skills
#
#  id              :text             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  job_id          :text             not null
#  master_skill_id :text             not null
#
# Foreign Keys
#
#  DesiredSkill_job_id_fkey  (job_id => jobs.id) ON DELETE => restrict ON UPDATE => cascade
#
class DesiredSkill < ApplicationRecord
  belongs_to :job

  def master_skill
    MasterSkill.find_by(id: master_skill_id)
  end
end
