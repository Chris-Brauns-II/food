# == Schema Information
#
# Table name: tags
#
#  id         :text             not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_many :job_tags, dependent: :delete_all
end
