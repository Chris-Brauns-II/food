class EmployerChats
  Recruiter = Struct.new(:user, :employer_id)

  def initialize(recruiter:, message_service:)
    @recruiter = recruiter
    @message_service = message_service
  end

  def get
    Chats::ApplicantChat
      .includes(:messages, :read_receipts)
      .where(employer_id: recruiter.employer_id).map do |applicant_chat|
      read_until = applicant_chat.read_receipts.select { |r| r.user_id == recruiter.user.id }.first&.read_until || Time.zone.at(0)

      {
        id: applicant_chat.application_id,
        name: applicant_chat.title,
        updatedAt: applicant_chat.chat_updated_at,
        messages: applicant_chat.messages.sort_by(&:message_sent_at).map do |message|
          {
            id: message.id,
            text: message.message,
            isUser: message.user_id == recruiter.user.id,
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
        read_by_user_id: recruiter.user.id
      }
    )
  end

  def send_message(application_id:, message:)
    message_service.create!(
      schema: Events::ChatMessageSent::V2,
      application_id:,
      data: {
        from_name: "#{recruiter.user.first_name} #{recruiter.user.last_name}",
        from_user_id: recruiter.user.id,
        message:
      }
    )
  end

  def create(application_id:, job_id:, seeker_id:, title:)
    message_service.create_once_for_stream!(
      schema: Events::ChatCreated::V2,
      application_id:,
      data: {
        employer_id: recruiter.employer_id,
        job_id:,
        seeker_id:,
        title:
      }
    )
  end

  private

  attr_reader :recruiter, :message_service
end
