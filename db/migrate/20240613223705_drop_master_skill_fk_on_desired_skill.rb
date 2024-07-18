class DropMasterSkillFkOnDesiredSkill < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :desired_skills, :master_skills
  end
end
