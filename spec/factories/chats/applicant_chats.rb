FactoryBot.define do
  factory :chats__applicant_chat, class: "Chats::ApplicantChat" do
    chat_created_at { Time.zone.local(2024, 1, 1) }
    chat_updated_at { Time.zone.local(2024, 1, 1) }
    title { "Let's chat!" }
    application_id { SecureRandom.uuid }
    employer_id { SecureRandom.uuid }
    seeker_id { SecureRandom.uuid }
  end
end
