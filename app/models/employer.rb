# == Schema Information
#
# Table name: employers
#
#  id           :text             not null, primary key
#  name         :text             not null
#  location     :text
#  bio          :text             not null
#  logo_url     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_enabled :boolean          default(FALSE), not null
#
class Employer < ApplicationRecord
  has_many :jobs, dependent: :destroy
end
