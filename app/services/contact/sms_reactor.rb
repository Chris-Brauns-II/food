module Contact
  class SmsReactor < MessageReactor
    def initialize(sms_service: Sms::Gateway.build, **params)
      super(**params)
      @sms_service = sms_service
    end

    on_message Commands::SendSmsMessage::V3 do |message|
      sms_service.send_message(
        phone_number: message.data.phone_number,
        message: message.data.message
      )

      message_service.create!(
        schema: Events::SmsMessageSent::V2,
        message_id: message.stream.message_id,
        trace_id: message.trace_id,
        data: {
          phone_number: message.data.phone_number,
          message: message.data.message
        }
      )
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    private

    attr_reader :sms_service
  end
end
