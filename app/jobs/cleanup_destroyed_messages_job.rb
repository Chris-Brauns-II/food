class CleanupDestroyedMessagesJob < ApplicationJob
  queue_as :default

  def perform
    MessageService.all_schemas.select(&:destroyed?).each do |schema|
      Event.where(version: schema.version, event_type: schema.message_type).delete_all
    end
  end
end
