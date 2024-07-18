FactoryBot.define do
  factory :job_orders__person, class: "JobOrders::Person" do
    id { SecureRandom.uuid }
    email { "seeker@skillarc.com" }
    first_name { "Seeker" }
    last_name { "Skillz" }
    phone_number { "+13333333333" }
  end
end
