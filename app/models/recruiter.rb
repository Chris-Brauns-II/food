# == Schema Information
#
# Table name: recruiters
#
#  id          :text             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  employer_id :text             not null
#  user_id     :text             not null
#
# Foreign Keys
#
#  Recruiter_user_id_fkey  (user_id => users.id) ON DELETE => restrict ON UPDATE => cascade
#
class Recruiter < ApplicationRecord
  belongs_to :user
end
