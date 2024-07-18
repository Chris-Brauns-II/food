# == Schema Information
#
# Table name: job_orders_job_orders
#
#  id                 :uuid             not null, primary key
#  applicant_count    :integer          not null
#  candidate_count    :integer          not null
#  closed_at          :datetime
#  hire_count         :integer          not null
#  opened_at          :datetime         not null
#  order_count        :integer
#  recommended_count  :integer          not null
#  screened_count     :integer
#  status             :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  job_orders_jobs_id :uuid             not null
#  team_id            :uuid
#
# Indexes
#
#  index_job_orders_job_orders_on_job_orders_jobs_id  (job_orders_jobs_id)
#  index_job_orders_job_orders_on_status              (status)
#
# Foreign Keys
#
#  fk_rails_...  (job_orders_jobs_id => job_orders_jobs.id)
#
module JobOrders
  class JobOrder < ApplicationRecord
    belongs_to :job, class_name: "JobOrders::Job", foreign_key: "job_orders_jobs_id", inverse_of: :job_orders
    has_many :candidates, class_name: "JobOrders::Candidate", inverse_of: :job_order, dependent: :delete_all
    has_many :notes, class_name: "JobOrders::Note", inverse_of: :job_order, dependent: :delete_all

    scope :active, -> { where(status: ActivatedStatus::ALL) }

    def self.for_applicable_jobs
      includes(:job).where(job_orders_jobs: { applicable_for_job_orders: true })
    end
  end
end
