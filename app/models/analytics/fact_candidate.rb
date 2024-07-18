# == Schema Information
#
# Table name: analytics_fact_candidates
#
#  id                          :bigint           not null, primary key
#  added_at                    :datetime         not null
#  email                       :string
#  employer_name               :string
#  employment_title            :string
#  first_name                  :string
#  last_name                   :string
#  order_candidate_number      :integer          not null
#  status                      :string           not null
#  terminal_status_at          :datetime
#  analytics_dim_job_orders_id :bigint           not null
#  analytics_dim_people_id     :bigint           not null
#
# Indexes
#
#  index_analytics_fact_candidates_on_analytics_dim_job_orders_id  (analytics_dim_job_orders_id)
#  index_analytics_fact_candidates_on_analytics_dim_people_id      (analytics_dim_people_id)
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_job_orders_id => analytics_dim_job_orders.id)
#  fk_rails_...  (analytics_dim_people_id => analytics_dim_people.id)
#
module Analytics
  class FactCandidate < ApplicationRecord
    belongs_to :dim_job_order, class_name: "Analytics::DimJobOrder", foreign_key: "analytics_dim_job_orders_id", inverse_of: :fact_candidates
    belongs_to :dim_person, class_name: "Analytics::DimPerson", foreign_key: "analytics_dim_people_id", inverse_of: :fact_candidates
  end
end
