# == Schema Information
#
# Table name: analytics_dim_job_orders
#
#  id                    :bigint           not null, primary key
#  closed_at             :datetime
#  closed_status         :string
#  employer_name         :string
#  employment_title      :string
#  order_count           :integer
#  order_opened_at       :datetime         not null
#  analytics_dim_jobs_id :bigint           not null
#  job_order_id          :uuid             not null
#
# Indexes
#
#  index_analytics_dim_job_orders_on_analytics_dim_jobs_id  (analytics_dim_jobs_id)
#  index_analytics_dim_job_orders_on_job_order_id           (job_order_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_jobs_id => analytics_dim_jobs.id)
#
module Analytics
  class DimJobOrder < ApplicationRecord
    belongs_to :dim_job, class_name: "Analytics::DimJob", foreign_key: "analytics_dim_jobs_id", inverse_of: :dim_jobs

    has_many :fact_candidates, class_name: "Analytics::FactCandidate", inverse_of: :dim_job_order, dependent: :delete_all
  end
end
