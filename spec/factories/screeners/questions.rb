FactoryBot.define do
  factory :screeners__questions, class: "Screeners::Questions" do
    title { "Questions" }
    questions { ["Where's my car?"] }
  end
end
