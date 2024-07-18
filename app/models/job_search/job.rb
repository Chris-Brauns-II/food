# == Schema Information
#
# Table name: search_jobs
#
#  id                 :bigint           not null, primary key
#  category           :string           not null
#  employer_logo_url  :text
#  employer_name      :string           not null
#  employment_title   :string           not null
#  employment_type    :string           not null
#  hidden             :boolean          default(FALSE), not null
#  industries         :string           default([]), is an Array
#  location           :text             not null
#  starting_lower_pay :integer
#  starting_upper_pay :integer
#  tags               :string           default([]), is an Array
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  employer_id        :uuid             not null
#  job_id             :uuid             not null
#
# Indexes
#
#  index_search_jobs_on_employer_name     (employer_name)
#  index_search_jobs_on_employment_title  (employment_title)
#  index_search_jobs_on_employment_type   (employment_type)
#  index_search_jobs_on_industries        (industries)
#  index_search_jobs_on_job_id            (job_id) UNIQUE
#  index_search_jobs_on_location          (location)
#  index_search_jobs_on_tags              (tags)
#
module JobSearch
  class Job < ApplicationRecord
    self.table_name = "search_jobs"

    has_many :applications, inverse_of: :search_job, dependent: :destroy, class_name: "JobSearch::Application", foreign_key: "search_job_id"
    has_many :saved_jobs, inverse_of: :search_job, dependent: :destroy, class_name: "JobSearch::SavedJob", foreign_key: "search_job_id"

    scope :shown, -> { where(hidden: false) }
  end
end
