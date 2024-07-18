module Contact
  class ContactAggregator < MessageConsumer
    def reset_for_replay
      Contact::Notification.delete_all
    end

    on_message Events::NotificationCreated::V3, :sync do |message|
      Contact::Notification.create!(
        id: message.data.notification_id,
        user_id: message.data.user_id,
        title: message.data.title,
        body: message.data.body,
        url: message.data.url
      )
    end

    on_message Events::NotificationMarkedRead::V2, :sync do |message|
      notification = Contact::Notification.where(id: message.data.notification_ids)
      notification.update_all(read_at: message.occurred_at) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
