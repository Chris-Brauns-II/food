class Message
  InvalidSchemaError = Class.new(StandardError)

  MESSAGE_UUID_NAMESPACE = "3e1e29c9-0fff-437c-92a7-531ca1b744b1".freeze

  delegate :id, to: :stream, prefix: true

  include(ValueSemantics.for_attributes do
    id Uuid
    stream Core::Stream
    trace_id Uuid
    schema Core::Schema
    data
    metadata
    occurred_at ActiveSupport::TimeWithZone, coerce: Core::TimeZoneCoercer
  end)

  def initialize(**kwarg)
    super

    raise InvalidSchemaError unless schema.stream === stream # rubocop:disable Style/CaseEquality
    raise InvalidSchemaError unless schema.data === data # rubocop:disable Style/CaseEquality
    raise InvalidSchemaError unless schema.metadata === metadata # rubocop:disable Style/CaseEquality
  end

  def serialize
    {
      id:,
      stream: stream.serialize,
      trace_id:,
      schema: schema.serialize,
      data: data.serialize,
      metadata: metadata.serialize,
      occurred_at:
    }
  end

  def self.deserialize(hash)
    schema = Core::Schema.deserialize(hash[:schema])

    new(
      id: hash[:id],
      stream: schema.stream.deserialize(hash[:stream]),
      schema:,
      trace_id: hash[:trace_id],
      data: schema.data.deserialize(hash[:data]),
      metadata: schema.metadata.deserialize(hash[:metadata]),
      occurred_at: hash[:occurred_at]
    )
  end

  def ==(other)
    self.class == other.class &&
      schema == other.schema &&
      stream == other.stream &&
      id == other.id &&
      occurred_at == other.occurred_at &&
      data == other.data &&
      metadata == other.metadata
  end
end
