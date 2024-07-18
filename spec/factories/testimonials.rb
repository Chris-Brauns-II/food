FactoryBot.define do
  factory :testimonial do
    job
    id { SecureRandom.uuid }
    name { "Hannah" }
    title { "Software Engineer" }
    testimonial { "I love working at Blocktrain!" }
    photo_url { "https://picsum.photos/200/300" }
  end
end
