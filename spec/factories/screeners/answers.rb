FactoryBot.define do
  factory :screeners__answers, class: "Screeners::Answers" do
    questions factory: %i[screeners__questions]
    title { "Questions Responses" }
    person_id { SecureRandom.uuid }
    question_responses { [{ question: "Dude where's my care", response: "No idea" }] }
  end
end
