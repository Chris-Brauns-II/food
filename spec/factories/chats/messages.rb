FactoryBot.define do
  factory :chats__message, class: "Chats::Message" do
    applicant_chat factory: %i[chats__applicant_chat]

    message_sent_at { Time.zone.local(2002, 1, 1) }
    user_id { SecureRandom.uuid }
    from { "Santa Claus" }
    message { "Sup!" }
  end
end
