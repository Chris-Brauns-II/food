class MessageService
  NotSchemaError = Class.new(StandardError)
  NotStreamError = Class.new(StandardError)
  NotTraceIdError = Class.new(StandardError)
  SchemaAlreadyDefinedError = Class.new(StandardError)
  MessageTypeHasMultipleActiveSchemas = Class.new(StandardError)
  SchemaNotFoundError = Class.new(StandardError)
  InactiveSchemaError = Class.new(StandardError)
  NotBooleanProjection = Class.new(StandardError)

  def create_once_for_trace!(schema:, data:, stream: nil, trace_id: SecureRandom.uuid, id: SecureRandom.uuid, occurred_at: Time.zone.now, metadata: Core::Nothing, **) # rubocop:disable Metrics/ParameterLists
    stream = get_stream(stream:, schema:, **)
    message = build(schema:, data:, trace_id:, id:, occurred_at:, metadata:, stream:, **)

    projection = Projectors::Trace::HasOccurred.project(trace_id:, schema:)
    raise MessageService::NotBooleanProjection unless [true, false].include?(projection)

    save!(message) unless projection

    message
  end

  def create_once_for_stream!(schema:, data:, stream: nil, trace_id: SecureRandom.uuid, id: SecureRandom.uuid, occurred_at: Time.zone.now, metadata: Core::Nothing, **) # rubocop:disable Metrics/ParameterLists
    stream = get_stream(stream:, schema:, **)
    message = build(schema:, data:, trace_id:, id:, occurred_at:, metadata:, stream:, **)

    projection = Projectors::Streams::HasOccurred.project(stream:, schema:)
    raise MessageService::NotBooleanProjection unless [true, false].include?(projection)

    save!(message) unless projection

    message
  end

  def create!(schema:, data:, stream: nil, trace_id: SecureRandom.uuid, id: SecureRandom.uuid, occurred_at: Time.zone.now, metadata: Core::Nothing, **) # rubocop:disable Metrics/ParameterLists
    message = build(schema:, data:, trace_id:, id:, occurred_at:, metadata:, stream:, **)
    save!(message)

    message
  end

  def build(schema:, data:, stream: nil, trace_id: SecureRandom.uuid, id: SecureRandom.uuid, occurred_at: Time.zone.now, metadata: Core::Nothing, **) # rubocop:disable Metrics/ParameterLists
    raise NotSchemaError unless schema.is_a?(Core::Schema)

    raise InactiveSchemaError, "Attempted to create message for #{schema}" if schema.inactive?

    stream = get_stream(stream:, schema:, **)

    data = schema.data.new(**data) if data.is_a?(Hash)
    metadata = schema.metadata.new(**metadata) if metadata.is_a?(Hash)

    Message.new(
      id:,
      stream:,
      occurred_at:,
      data:,
      trace_id:,
      metadata:,
      schema:
    )
  end

  def save!(message)
    Event.from_message!(message)

    messages_to_publish << message
  end

  def flush
    # uniquely determine which event type have occurred
    schema_strings = messages_to_publish.map { |m| m.schema.to_s }.uniq
    @messages_to_publish = []

    # dedup all async subscribers
    async_subscribers = schema_strings.flat_map do |schema_string|
      ASYNC_SUBSCRIBERS.get_subscribers_for_schema(schema_string:)
    end.uniq

    # publish all execute job at once
    ActiveJob.perform_all_later(async_subscribers.map { |subscriber| ExecuteSubscriberJob.new(subscriber_id: subscriber.id) }) if broadcast?

    # get each sync subscriber uniquely
    subscribers = schema_strings.flat_map do |schema_string|
      SYNC_SUBSCRIBERS.get_subscribers_for_schema(schema_string:)
    end.uniq

    # play each once
    subscribers.each(&:play)
  end

  def broadcast?
    !Rails.env.test?
  end

  def self.register(schema:)
    raise NotSchemaError unless schema.is_a?(Core::Schema)

    registry[schema.message_type] ||= {}

    if schema.message_type != MessageTypes::TestingOnly::TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST
      raise SchemaAlreadyDefinedError, "The message #{schema} was overritten" if registry[schema.message_type][schema.version].present?
      raise MessageTypeHasMultipleActiveSchemas, "The message_type #{schema.message_type} has multiple active schemas" if schema.active? && registry[schema.message_type].values.any?(&:active?)
    end

    registry[schema.message_type][schema.version] = schema
  end

  def self.get_schema(message_type:, version:)
    schema = registry.dig(message_type, version)
    raise SchemaNotFoundError, "event_type: #{message_type} version: #{version}" if schema.blank?

    schema
  end

  def self.all_messages(schema)
    raise NotSchemaError unless schema.is_a?(Core::Schema)

    order_and_map(Event.where(version: schema.version, event_type: schema.message_type))
  end

  def self.stream_events(stream)
    raise NotStreamError unless stream.is_a?(Core::Stream)

    order_and_map(Event.where(aggregate_id: stream.id)).select { |m| m.schema.type == Core::EVENT }
  end

  def self.trace_id_events(trace_id)
    raise NotTraceIdError unless trace_id.is_a?(String)

    order_and_map(Event.where(trace_id:)).select { |m| m.schema.type == Core::EVENT }
  end

  def self.migrate_event(schema:, &block)
    Event.where(event_type: schema.message_type, version: schema.version).find_each do |e|
      block.call(e.message)
    end
  end

  def self.all_schemas
    registry.to_a.map do |_event_type, versions|
      versions.map do |_version, event_schema|
        event_schema
      end
    end.flatten
  end

  private

  def get_stream(stream:, schema:, **)
    stream || schema.stream.new(**)
  end

  def messages_to_publish
    @messages_to_publish ||= []
  end

  class << self
    private

    def order_and_map(message_relation)
      message_relation.order(:occurred_at, :id).map(&:message)
    end

    def registry
      @registry ||= {}
    end
  end
end
