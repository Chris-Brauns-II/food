FactoryBot.define do
  factory :coaches__feed_event, class: "Coaches::FeedEvent" do
    context_id { SecureRandom.uuid }
    seeker_email { Faker::Internet.email }
    occurred_at { Time.current }
    description { Faker::Lorem.sentence }
  end
end
