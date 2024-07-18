# == Schema Information
#
# Table name: events
#
#  id           :uuid             not null, primary key
#  data         :jsonb            not null
#  event_type   :string           not null
#  metadata     :jsonb            not null
#  occurred_at  :datetime         not null
#  version      :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  aggregate_id :string           not null
#  trace_id     :uuid             not null
#
# Indexes
#
#  index_events_on_aggregate_id            (aggregate_id)
#  index_events_on_event_type              (event_type)
#  index_events_on_event_type_and_version  (event_type,version)
#  index_events_on_occurred_at             (occurred_at)
#  index_events_on_trace_id                (trace_id)
#
class Event < ApplicationRecord
  def message
    schema = MessageService.get_schema(message_type: event_type, version:)

    Message.new(
      id:,
      stream: schema.stream.new(**{ schema.stream.id => aggregate_id }),
      trace_id:,
      schema:,
      data: schema.data.deserialize(data),
      metadata: schema.metadata.deserialize(metadata),
      occurred_at:
    )
  end

  def self.from_message!(message)
    create!(
      id: message.id,
      aggregate_id: message.stream.id,
      trace_id: message.trace_id,
      event_type: message.schema.message_type,
      data: message.data.serialize,
      metadata: message.metadata.serialize,
      version: message.schema.version,
      occurred_at: message.occurred_at
    )
  end

  validates :event_type, presence: true, inclusion: { in: MessageTypes::ALL }

  private

  def aggregate_id
    self[:aggregate_id]
  end

  def event_type
    self[:event_type]
  end

  def data
    self[:data].deep_symbolize_keys
  end

  def metadata
    self[:metadata].deep_symbolize_keys
  end

  def version
    self[:version]
  end

  def occurred_at
    self[:occurred_at]
  end
end
