module Contact
  module CalDotCom
    class WebhookService
      extend MessageEmitter

      def self.handle_webhook(webhook)
        message_service.create!(
          schema: Events::CalWebhookReceived::V1,
          integration: "cal.com",
          data: {
            cal_trigger_event_type: webhook["triggerEvent"],
            payload: webhook["payload"].deep_symbolize_keys
          },
          occurred_at: webhook["createdAt"]
        )
      end
    end
  end
end
