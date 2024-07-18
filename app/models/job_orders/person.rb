# == Schema Information
#
# Table name: job_orders_people
#
#  id           :uuid             not null, primary key
#  email        :string
#  first_name   :string
#  last_name    :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
module JobOrders
  class Person < ApplicationRecord
    has_many :candidates, class_name: "JobOrders::Candidate", inverse_of: :person, dependent: :delete_all
  end
end
