# == Schema Information
#
# Table name: analytics_fact_applications
#
#  id                      :bigint           not null, primary key
#  application_number      :integer          not null
#  application_opened_at   :datetime         not null
#  application_updated_at  :datetime
#  status                  :string           not null
#  analytics_dim_job_id    :bigint           not null
#  analytics_dim_person_id :bigint           not null
#  application_id          :uuid             not null
#
# Indexes
#
#  index_analytics_fact_applications_on_analytics_dim_job_id     (analytics_dim_job_id)
#  index_analytics_fact_applications_on_analytics_dim_person_id  (analytics_dim_person_id)
#  index_analytics_fact_applications_on_application_id           (application_id)
#  index_analytics_fact_applications_on_application_number       (application_number)
#  index_analytics_fact_applications_on_status                   (status)
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_job_id => analytics_dim_jobs.id)
#  fk_rails_...  (analytics_dim_person_id => analytics_dim_people.id)
#
module Analytics
  class FactApplication < ApplicationRecord
    belongs_to :dim_job, class_name: "Analytics::DimJob", foreign_key: "analytics_dim_job_id", inverse_of: :fact_applications
    belongs_to :dim_person, class_name: "Analytics::DimPerson", foreign_key: "analytics_dim_person_id", inverse_of: :fact_applications
  end
end
