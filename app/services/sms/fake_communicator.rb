module Sms
  class FakeCommunicator < SmsCommunicator
    def send_message(phone_number:, message:)
      Rails.logger.info("FAKE - Sending message to #{phone_number}: #{message}")
    end
  end
end
