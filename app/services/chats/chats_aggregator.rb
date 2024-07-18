module Chats
  class ChatsAggregator < MessageConsumer
    def reset_for_replay
      ApplicantChat.delete_all
      Message.delete_all
      ReadReceipt.delete_all
    end

    on_message Events::ChatCreated::V2, :sync do |message|
      ApplicantChat.create!(
        application_id: message.stream.id,
        chat_created_at: message.occurred_at,
        chat_updated_at: message.occurred_at,
        employer_id: message.data.employer_id,
        seeker_id: message.data.seeker_id,
        title: message.data.title
      )
    end

    on_message Events::ChatMessageSent::V2, :sync do |message|
      applicant_chat = ApplicantChat.find_by!(application_id: message.stream.id)
      applicant_chat.update!(chat_updated_at: message.occurred_at)

      Message.create!(
        applicant_chat:,
        message_sent_at: message.occurred_at,
        user_id: message.data.from_user_id,
        from: message.data.from_name,
        message: message.data.message
      )
    end

    on_message Events::ChatRead::V1, :sync do |message|
      applicant_chat = ApplicantChat.find_by!(application_id: message.stream.id)

      read_receipt = ReadReceipt.find_or_initialize_by(
        applicant_chat:,
        user_id: message.data.read_by_user_id
      )

      read_receipt.update!(read_until: message.occurred_at)
    end
  end
end
