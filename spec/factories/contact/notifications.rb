FactoryBot.define do
  factory :contact__notification, class: 'Contact::Notification' do
    user_id { SecureRandom.uuid }
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    url { "/" }
  end
end
