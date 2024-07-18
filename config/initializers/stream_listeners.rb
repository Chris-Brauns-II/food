require 'subscriber_initializer'
require 'subscriber_registry'

ASYNC_SUBSCRIBERS = SubscriberRegistry.new
SYNC_SUBSCRIBERS = SubscriberRegistry.new

Rails.application.config.after_initialize do
  SubscriberInitializer.run
end

if Rails.env.development?
  Rails.application.reloader.to_prepare do
    SubscriberInitializer.run
  end
end
