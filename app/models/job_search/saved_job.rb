# == Schema Information
#
# Table name: search_saved_jobs
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  search_job_id :bigint           not null
#  user_id       :string           not null
#
# Indexes
#
#  index_search_saved_jobs_on_search_job_id  (search_job_id)
#  index_search_saved_jobs_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (search_job_id => search_jobs.id)
#
module JobSearch
  class SavedJob < ApplicationRecord
    self.table_name = "search_saved_jobs"

    belongs_to :search_job, class_name: "JobSearch::Job"
  end
end
