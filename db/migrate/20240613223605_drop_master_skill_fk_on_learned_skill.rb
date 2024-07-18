class DropMasterSkillFkOnLearnedSkill < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :learned_skills, :master_skills
  end
end
