class DropMasterSkillFkOnProfileSkill < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :profile_skills, :master_skills
  end
end
