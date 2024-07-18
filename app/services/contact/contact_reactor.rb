module Contact
  class ContactReactor < MessageReactor
    on_message Commands::SendMessage::V2 do |message|
      messages = MessageService.stream_events(Streams::Person.new(person_id: message.data.person_id))
      result = Projectors::ContactPreference.new.project(messages)

      case result.preference
      when Contact::ContactPreference::SLACK
        text = if message.data.url.present?
                 "*#{message.data.title}*: #{message.data.body} <#{message.data.url}|Link>"
               else
                 "*#{message.data.title}*: #{message.data.body}"
               end

        message_service.create!(
          schema: Commands::SendSlackMessage::V2,
          trace_id: message.trace_id,
          message_id: message.stream.message_id,
          data: {
            channel: result.slack_id,
            text:
          }
        )
        emit_message_enqueued(message)
      when Contact::ContactPreference::EMAIL
        message_service.create!(
          schema: Commands::SendEmailMessage::V1,
          trace_id: message.trace_id,
          message_id: message.stream.message_id,
          data: {
            recepent_email: result.email,
            title: message.data.title,
            body: message.data.body,
            url: message.data.url
          }
        )
        emit_message_enqueued(message)
      when Contact::ContactPreference::SMS
        text = if message.data.url.present?
                 "#{message.data.title}: #{message.data.body} #{message.data.url}"
               else
                 "#{message.data.title}: #{message.data.body}"
               end

        message_service.create!(
          schema: Commands::SendSmsMessage::V3,
          trace_id: message.trace_id,
          message_id: message.stream.message_id,
          data: {
            phone_number: result.phone_number,
            message: text
          }
        )
        emit_message_enqueued(message)
      when Contact::ContactPreference::IN_APP_NOTIFICATION
        message_service.create!(
          schema: Events::NotificationCreated::V3,
          trace_id: message.trace_id,
          message_id: message.stream.message_id,
          data: {
            title: message.data.title,
            body: message.data.body,
            url: message.data.url,
            notification_id: SecureRandom.uuid,
            user_id: result.notification_user_id
          }
        )
        message_service.create!(
          schema: Events::MessageSent::V1,
          trace_id: message.trace_id,
          message_id: message.stream.message_id,
          data: Core::Nothing
        )
      end
    end

    private

    def emit_message_enqueued(message)
      message_service.create!(
        schema: Events::MessageEnqueued::V1,
        trace_id: message.trace_id,
        message_id: message.stream.message_id,
        data: Core::Nothing
      )
    end
  end
end
