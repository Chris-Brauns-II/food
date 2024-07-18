FactoryBot.define do
  factory :message, class: "Message" do
    id { SecureRandom.uuid }

    transient do
      stream_id { SecureRandom.uuid }
    end

    schema { Events::SessionStarted::V1 }
    trace_id { SecureRandom.uuid }
    stream { schema.stream.new(**{ schema.stream.id => stream_id }) }
    occurred_at { Time.zone.local(2020, 1, 1) }
    data { nil }
    metadata { nil }

    initialize_with do
      data =
        if attributes[:data].is_a?(Hash)
          default_values = attributes[:schema].data.generate_default_attributes
          attributes[:schema].data.new(default_values.merge(attributes[:data]))
        elsif attributes[:data].nil?
          attributes[:schema].data.generate_default
        else
          attributes[:data]
        end
      metadata =
        if attributes[:metadata].is_a?(Hash)
          default_values = attributes[:schema].metadata.generate_default_attributes
          attributes[:schema].metadata.new(default_values.merge(attributes[:metadata]))
        elsif attributes[:metadata].nil?
          attributes[:schema].metadata.generate_default
        else
          attributes[:metadata]
        end

      raise Message::InvalidSchemaError if attributes[:schema].inactive? || attributes[:schema].destroyed?

      Message.new(
        **attributes,
        data:,
        metadata:
      )
    end
  end
end
