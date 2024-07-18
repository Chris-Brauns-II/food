FactoryBot.define do
  factory :coaches__person_note, class: "Coaches::PersonNote" do
    person_context factory: %i[coaches__person_context]

    note { "This is a note" }
    note_taken_at { Time.zone.local(2020, 1, 1) }
    note_taken_by { "coach@blocktrainapp.com" }
  end
end
