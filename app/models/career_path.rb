# == Schema Information
#
# Table name: career_paths
#
#  id          :text             not null, primary key
#  lower_limit :text             not null
#  order       :integer          not null
#  title       :text             not null
#  upper_limit :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  job_id      :text             not null
#
# Foreign Keys
#
#  CareerPath_job_id_fkey  (job_id => jobs.id) ON DELETE => restrict ON UPDATE => cascade
#
class CareerPath < ApplicationRecord
  belongs_to :job
end
