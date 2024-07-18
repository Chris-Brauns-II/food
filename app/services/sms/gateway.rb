module Sms
  class Gateway
    module Strategies
      ALL = [
        TWILIO = "twilio".freeze,
        FAKE = "fake".freeze
      ].freeze
    end

    SmsGatewayEnvvarNotSetError = Class.new(StandardError)

    def self.build(strategy: ENV.fetch("SMS_GATEWAY_STRATEGY", nil))
      case strategy
      when Strategies::TWILIO
        TwilioCommunicator.new
      when Strategies::FAKE
        FakeCommunicator.new
      else
        raise SmsGatewayEnvvarNotSetError
      end
    end
  end
end
