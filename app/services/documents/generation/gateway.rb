module Documents
  module Generation
    class Gateway
      module Strategies
        ALL = [
          REAL = "real".freeze,
          FAKE = "fake".freeze
        ].freeze
      end

      DocumentsGenerationGatewayEnvvarNotSetError = Class.new(StandardError)

      def self.build(strategy: ENV.fetch("DOCUMENT_GENERATION_STRATEGY", nil))
        case strategy
        when Strategies::REAL
          RealCommunicator.new
        when Strategies::FAKE
          FakeCommunicator.new
        else
          raise DocumentsGenerationGatewayEnvvarNotSetError
        end
      end
    end
  end
end
