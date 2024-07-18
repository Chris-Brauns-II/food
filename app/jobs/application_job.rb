class ApplicationJob < ActiveJob::Base
  queue_as :default
  sidekiq_options retry: 1, backtrace: 20
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
