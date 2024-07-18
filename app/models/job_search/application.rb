# == Schema Information
#
# Table name: search_applications
#
#  id             :bigint           not null, primary key
#  elevator_pitch :text
#  status         :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  application_id :uuid             not null
#  job_id         :uuid             not null
#  search_job_id  :bigint           not null
#  seeker_id      :uuid             not null
#
# Indexes
#
#  index_search_applications_on_application_id  (application_id)
#  index_search_applications_on_search_job_id   (search_job_id)
#  index_search_applications_on_seeker_id       (seeker_id)
#
# Foreign Keys
#
#  fk_rails_...  (search_job_id => search_jobs.id)
#
module JobSearch
  class Application < ApplicationRecord
    self.table_name = "search_applications"

    belongs_to :search_job, class_name: "JobSearch::Job"
  end
end
