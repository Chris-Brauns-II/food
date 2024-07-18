module Sms
  class SmsCommunicator
    def send_message(phone_number:, message:)
      raise NotImplementedError
    end
  end
end
