FactoryBot.define do
  factory :chats__read_receipt, class: "Chats::ReadReceipt" do
    applicant_chat factory: %i[chats__applicant_chat]

    read_until { Time.zone.local(2024, 1, 1) }
    user_id { SecureRandom.uuid }
  end
end
