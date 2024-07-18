# == Schema Information
#
# Table name: testimonials
#
#  id          :text             not null, primary key
#  name        :text             not null
#  photo_url   :text
#  testimonial :text             not null
#  title       :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  job_id      :text             not null
#
# Foreign Keys
#
#  Testimonial_job_id_fkey  (job_id => jobs.id) ON DELETE => restrict ON UPDATE => cascade
#
class Testimonial < ApplicationRecord
  belongs_to :job
end
