class SeekerChats
  def initialize(seeker:, message_service:)
    @seeker = seeker
    @message_service = message_service
  end

  def send_message(application_id:, message:)
    message_service.create!(
      schema: Events::ChatMessageSent::V2,
      application_id:,
      data: {
        from_user_id: seeker.user_id,
        from_name: "#{seeker.first_name} #{seeker.last_name}",
        message:
      }
    )
  end

  def get
    Chats::ApplicantChat
      .includes(:messages, :read_receipts)
      .where(seeker_id: seeker.id).map do |applicant_chat|
      read_until = applicant_chat.read_receipts.select { |r| r.user_id == seeker.user_id }.first&.read_until || Time.zone.at(0)

      {
        id: applicant_chat.application_id,
        name: applicant_chat.title,
        updatedAt: applicant_chat.chat_updated_at,
        messages: applicant_chat.messages.sort_by(&:message_sent_at).map do |message|
          {
            id: message.id,
            text: message.message,
            isUser: message.user_id == seeker.user_id,
            isRead: read_until > message.message_sent_at,
            sender: message.from
          }
        end
      }
    end
  end

  def mark_read(application_id:)
    message_service.create!(
      schema: Events::ChatRead::V1,
      application_id:,
      data: {
        read_by_user_id: seeker.user_id
      }
    )
  end

  private

  attr_reader :seeker, :message_service
end
