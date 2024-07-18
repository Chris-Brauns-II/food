# == Schema Information
#
# Table name: job_photos
#
#  id         :text             not null, primary key
#  photo_url  :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  job_id     :text             not null
#
# Foreign Keys
#
#  JobPhoto_job_id_fkey  (job_id => jobs.id) ON DELETE => restrict ON UPDATE => cascade
#
class JobPhoto < ApplicationRecord
  belongs_to :job
end
