FactoryBot.define do
  factory :event do
    transient do
      schema { Events::ChatMessageSent::V1 }
    end

    id { SecureRandom.uuid }
    aggregate_id { SecureRandom.uuid }
    trace_id { SecureRandom.uuid }
    event_type { schema.message_type }

    version { schema.version }
    occurred_at { Time.zone.local(2020, 1, 1) }
    data { {} }
    metadata { {} }
  end
end
