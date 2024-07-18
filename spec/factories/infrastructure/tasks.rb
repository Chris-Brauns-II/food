FactoryBot.define do
  factory :infrastructure__task, class: "Infrastructure::Task" do
    id { SecureRandom.uuid }
    execute_at { Time.zone.local(2020, 1, 1) }
    state { Infrastructure::TaskStates::ENQUEUED }
    command do
      Message.new(
        id: SecureRandom.uuid,
        trace_id: SecureRandom.uuid,
        schema: Commands::AssignCoach::V2,
        stream: Streams::Person.new(person_id: SecureRandom.uuid),
        data: Commands::AssignCoach::V2.data.new(
          coach_id: SecureRandom.uuid
        ),
        metadata: Core::Nothing,
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end
  end
end
