FactoryBot.define do
  factory :job_freshness do
    occurred_at { Date.new(2021, 1, 1) }
  end
end
