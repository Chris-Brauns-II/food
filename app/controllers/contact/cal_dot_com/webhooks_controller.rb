module Contact
  module CalDotCom
    class WebhooksController < ApplicationController
      include MessageEmitter

      def create
        key = ENV.fetch('CAL_COM_WEBHOOK_SECRET_KEY', "not-provided")

        hmac = OpenSSL::HMAC.hexdigest("SHA256", key, request.raw_post)
        expected_hmac = request.headers["X-Cal-Signature-256"]

        if hmac != expected_hmac
          head :forbidden
          return
        end

        params.permit!

        with_message_service do
          WebhookService.handle_webhook(params.to_h)
        end

        head :accepted
      end
    end
  end
end
