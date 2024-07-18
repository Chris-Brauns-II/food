# == Schema Information
#
# Table name: job_orders_candidates
#
#  id                       :uuid             not null, primary key
#  added_at                 :datetime         not null
#  applied_at               :datetime
#  recommended_at           :datetime
#  recommended_by           :string
#  status                   :string           not null
#  status_updated_at        :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  job_orders_job_orders_id :uuid             not null
#  job_orders_people_id     :uuid             not null
#
# Indexes
#
#  index_job_orders_candidates_on_job_orders_job_orders_id  (job_orders_job_orders_id)
#  index_job_orders_candidates_on_job_orders_people_id      (job_orders_people_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_orders_job_orders_id => job_orders_job_orders.id)
#  fk_rails_...  (job_orders_people_id => job_orders_people.id)
#
module JobOrders
  class Candidate < ApplicationRecord
    belongs_to :job_order, class_name: "JobOrders::JobOrder", foreign_key: "job_orders_job_orders_id", inverse_of: :candidates
    belongs_to :person, class_name: "JobOrders::Person", foreign_key: "job_orders_people_id", inverse_of: :candidates

    def job_order_id
      job_orders_job_orders_id
    end

    def person_id
      job_orders_people_id
    end
  end
end
