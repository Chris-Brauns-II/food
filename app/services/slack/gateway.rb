module Slack
  class Gateway
    GatewayEnvvarNotSetError = Class.new(StandardError)

    def self.build
      case ENV.fetch("SLACK_GATEWAY_STRATEGY", nil)
      when "real"
        Slack::Web::Client.new
      when "fake"
        Slack::FakeClient.new
      else
        raise GatewayEnvvarNotSetError
      end
    end
  end
end
