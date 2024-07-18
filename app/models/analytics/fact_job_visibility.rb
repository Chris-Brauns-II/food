# == Schema Information
#
# Table name: analytics_fact_job_visibilities
#
#  id                   :bigint           not null, primary key
#  visible_ending_at    :datetime
#  visible_starting_at  :datetime         not null
#  analytics_dim_job_id :bigint           not null
#
# Indexes
#
#  index_analytics_fact_job_visibilities_on_analytics_dim_job_id  (analytics_dim_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_job_id => analytics_dim_jobs.id)
#
module Analytics
  class FactJobVisibility < ApplicationRecord
    belongs_to :dim_job, class_name: "Analytics::DimJob", foreign_key: "analytics_dim_job_id", inverse_of: :fact_job_visibilities
  end
end
