class DbStreamListener < StreamListener
  delegate :all_handled_messages, to: :consumer
  delegate :handled_messages, to: :consumer
  delegate :handled_messages_sync, to: :consumer

  STRIDE = 500
  DEFAULT_EVENT_ID = "00000000-0000-0000-0000-000000000000".freeze

  attr_reader :listener_name

  def id
    "db-stream-#{listener_name}"
  end

  def self.build(consumer:, listener_name:, stride: STRIDE, now: Time.zone.now)
    listener = new(consumer:, listener_name:, now:, stride:)
    StreamListener.register(listener_name, listener)
    listener
  end

  def play
    Sentry.with_scope do |scope|
      scope.set_tags(stream_listener: id)
      crumb = Sentry::Breadcrumb.new(
        category: "event-sourcing",
        message: "Playing stream #{id}",
        level: "info"
      )
      Sentry.add_breadcrumb(crumb)

      bookmark = load_bookmark
      loop do
        event_length = 0

        bookmark.with_lock do
          events = unplayed_messages(bookmark).take(stride)
          event_length = events.length
          last_handled_event = nil

          events.each do |event|
            handle_message(event.message)
            last_handled_event = event
          end

          update_bookmark(bookmark, last_handled_event) if last_handled_event
        end

        break if event_length != stride
      end

      consumer.flush
    end
  end

  def replay
    return unless consumer.can_replay?

    consumer.reset_for_replay

    ListenerBookmark.find_by(consumer_name: listener_name)&.destroy
    play
  end

  def next_message
    bookmark = load_bookmark
    unplayed_messages(bookmark).take.first.message
  end

  private

  def load_bookmark
    # Note we are intentionally using insert which does nothing on conflict. This allow the
    # stream listen to assume there is a completely filled listener bookmark which
    # simplifies the rest of the code here.
    ListenerBookmark.insert({ consumer_name: listener_name, event_id: DEFAULT_EVENT_ID, current_timestamp: default_time }) # rubocop:disable Rails/SkipsModelValidations
    ListenerBookmark.find_by!(consumer_name: listener_name)
  end

  def unplayed_messages(bookmark)
    Event.where("occurred_at > ?", bookmark.current_timestamp)
         .or(Event.where("occurred_at = ? AND id > ?", bookmark.current_timestamp, bookmark.event_id))
         .order(:occurred_at, :id)
  end

  def initialize(consumer:, listener_name:, now:, stride:) # rubocop:disable Lint/MissingSuper
    @consumer = consumer
    @listener_name = listener_name
    @stride = stride
    @default_time = consumer.can_replay? ? Time.zone.at(0) : now
  end

  def update_bookmark(bookmark, event)
    bookmark.update!(
      event_id: event.id,
      current_timestamp: event.message.occurred_at
    )
  end

  attr_reader :default_time, :consumer, :stride

  def handle_message(message)
    consumer.handle_message(message)
  end
end
