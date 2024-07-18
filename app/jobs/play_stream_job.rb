class PlayStreamJob < ApplicationJob
  queue_as :default

  def perform(listener_name:)
    listener = StreamListener.get_listener(listener_name)
    return if listener.blank?

    listener.play
  end
end
