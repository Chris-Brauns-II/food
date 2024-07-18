# == Schema Information
#
# Table name: stories
#
#  id         :text             not null, primary key
#  prompt     :text             not null
#  response   :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  seeker_id  :uuid             not null
#
# Indexes
#
#  index_stories_on_seeker_id  (seeker_id)
#
# Foreign Keys
#
#  fk_rails_...  (seeker_id => seekers.id)
#
class Story < ApplicationRecord
  belongs_to :seeker
end
