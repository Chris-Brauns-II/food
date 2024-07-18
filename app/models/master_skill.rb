# frozen_string_literal: true

# == Schema Information
#
# Table name: master_skills
#
#  id         :text             not null, primary key
#  skill      :text             not null
#  type       :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MasterSkill < ApplicationRecord
  module SkillTypes
    ALL = [
      TECHNICAL = 'TECHNICAL',
      PERSONAL = 'PERSONAL'
    ].freeze
  end

  self.inheritance_column = nil
end
