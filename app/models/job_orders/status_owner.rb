# == Schema Information
#
# Table name: job_orders_status_owners
#
#  id           :bigint           not null, primary key
#  order_status :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  team_id      :uuid             not null
#
# Indexes
#
#  index_job_orders_status_owners_on_order_status  (order_status) UNIQUE
#
module JobOrders
  class StatusOwner < ApplicationRecord
  end
end
