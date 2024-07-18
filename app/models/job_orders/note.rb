# == Schema Information
#
# Table name: job_orders_notes
#
#  id                       :uuid             not null, primary key
#  note                     :string           not null
#  note_taken_at            :datetime         not null
#  note_taken_by            :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  job_orders_job_orders_id :uuid             not null
#
# Indexes
#
#  index_job_orders_notes_on_job_orders_job_orders_id  (job_orders_job_orders_id)
#
module JobOrders
  class Note < ApplicationRecord
    belongs_to :job_order, class_name: "JobOrders::JobOrder", foreign_key: "job_orders_job_orders_id", inverse_of: :notes
  end
end
