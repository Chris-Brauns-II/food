# == Schema Information
#
# Table name: analytics_dim_jobs
#
#  id                        :bigint           not null, primary key
#  category                  :string           not null
#  employer_name             :string
#  employment_title          :string           not null
#  employment_type           :string           not null
#  job_created_at            :datetime         not null
#  analytics_dim_employer_id :bigint           not null
#  job_id                    :uuid             not null
#
# Indexes
#
#  index_analytics_dim_jobs_on_analytics_dim_employer_id  (analytics_dim_employer_id)
#  index_analytics_dim_jobs_on_employment_type            (employment_type)
#  index_analytics_dim_jobs_on_job_id                     (job_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_employer_id => analytics_dim_employers.id)
#
module Analytics
  class DimJob < ApplicationRecord
    belongs_to :dim_employer, class_name: "Analytics::DimEmployer", foreign_key: "analytics_dim_employer_id", inverse_of: :dim_jobs
    has_many :dim_jobs, class_name: "Analytics::DimJobOrder", dependent: :delete_all

    has_many :fact_applications, class_name: "Analytics::FactApplication", dependent: :delete_all
    has_many :fact_job_visibilities, class_name: "Analytics::FactJobVisibility", dependent: :delete_all
  end
end
