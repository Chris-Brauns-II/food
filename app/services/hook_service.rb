class HookService
  include MessageEmitter

  def create_notification(email:, title:, body:, url:)
    user = User.find_by!(email:)

    message_service.create!(
      schema: Events::NotificationCreated::V3,
      message_id: SecureRandom.uuid,
      data: {
        user_id: user.id,
        notification_id: SecureRandom.uuid,
        title:,
        body:,
        url:
      }
    )
  end
end
