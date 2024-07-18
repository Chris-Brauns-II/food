FactoryBot.define do
  factory :coaches__reminder, class: "Coaches::Reminder" do
    coach factory: %i[coaches__coach]

    note { "Do the thing" }
    reminder_at { 2.days.from_now }
    state { Coaches::ReminderState::SET }
    person_id { nil }
    message_task_id { SecureRandom.uuid }
  end
end
