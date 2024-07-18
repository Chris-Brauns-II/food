class SubscriberRegistry
  attr_reader :subscribers, :subscribers_registry

  NotStreamListenerError = Class.new(StandardError)

  def initialize
    @subscribers_registry = {}
    @subscribers = {}
  end

  def get_subscriber(subscriber_id:)
    subscribers_registry[subscriber_id]
  end

  def get_subscribers_for_schema(schema_string:)
    subscribers[schema_string]&.values || []
  end

  def subscribe(schema:, subscriber:)
    raise NotStreamListenerError unless subscriber.class <= StreamListener

    schema_string = schema.to_s
    subscribers[schema_string] ||= {}
    subscribers[schema_string][subscriber.id] = subscriber

    subscribers_registry[subscriber.id] = subscriber
  end

  def reset
    @subscribers = {}
    @subscribers_registry = {}
  end
end
