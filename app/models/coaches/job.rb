# == Schema Information
#
# Table name: coaches_jobs
#
#  id               :uuid             not null, primary key
#  employer_name    :string
#  employment_title :string           not null
#  hide_job         :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  job_id           :uuid             not null
#
# Indexes
#
#  index_coaches_jobs_on_job_id  (job_id)
#
module Coaches
  class Job < ApplicationRecord
    has_many :job_recommendations, class_name: "Coaches::PersonJobRecommendation", dependent: :destroy, inverse_of: :job

    scope :visible, -> { where(hide_job: false) }
  end
end
