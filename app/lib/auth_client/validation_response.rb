module AuthClient
  class ValidationResponse
    ErrorResponseError = Class.new(StandardError)
    SuccessResponseError = Class.new(StandardError)

    def sub
      raise ErrorResponseError unless success?

      @sub
    end

    def message
      raise SuccessResponseError if success?

      @message
    end

    def status
      raise SuccessResponseError if success?

      @status
    end

    def success?
      @sub.present?
    end

    def self.ok(sub:)
      new(sub:)
    end

    def self.err(message:, status:)
      new(message:, status:)
    end

    private

    def initialize(sub: nil, message: nil, status: nil)
      @sub = sub
      @message = message
      @status = status
    end
  end
end
