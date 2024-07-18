class NotificationsController < ApplicationController
  include MessageEmitter
  include Secured

  before_action :authorize

  def mark_read
    notification_ids = Contact::Notification.unread.where(user_id: current_user.id).pluck(:id)

    with_message_service do
      message_service.create!(
        schema: Events::NotificationMarkedRead::V2,
        user_id: current_user.id,
        data: {
          notification_ids:
        }
      )
    end

    render json: { success: true }
  end
end
