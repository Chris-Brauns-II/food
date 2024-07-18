class ExecuteSubscriberJob < ApplicationJob
  queue_as :default

  def perform(subscriber_id:)
    ASYNC_SUBSCRIBERS.get_subscriber(subscriber_id:).play
  end
end
