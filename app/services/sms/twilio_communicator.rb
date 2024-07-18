module Sms
  class TwilioCommunicator < SmsCommunicator
    def initialize(from_number: ENV.fetch("TWILIO_FROM_NUMBER", nil), auth_token: ENV.fetch("TWILIO_AUTH_TOKEN", nil), account_sid: ENV.fetch("TWILIO_ACCOUNT_SID", nil))
      super()

      @from_number = from_number
      @auth_token = auth_token
      @account_sid = account_sid

      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end

    def send_message(phone_number:, message:)
      normalized_phone_number = E164.normalize(phone_number)

      client.messages.create(
        body: message,
        from: from_number,
        to: normalized_phone_number
      )
    end

    private

    attr_reader :from_number, :auth_token, :account_sid, :client
  end
end
