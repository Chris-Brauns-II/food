module Slack
  class FakeClient
    def chat_postMessage(**kwargs) # rubocop:disable Naming/MethodName
      Rails.logger.info("[Slack Message to #{kwargs[:channel]}]: #{kwargs[:text]} - (blocks #{kwargs[:block].to_json})")
    end
  end
end
