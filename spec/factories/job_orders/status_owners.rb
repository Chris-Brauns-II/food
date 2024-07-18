FactoryBot.define do
  factory :job_orders__status_owner, class: "JobOrders::StatusOwner" do
    team_id { SecureRandom.uuid }
    order_status { JobOrders::ActivatedStatus::OPEN }
  end
end
