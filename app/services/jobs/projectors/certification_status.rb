module Jobs
  module Projectors
    class CertificationStatus < Projector
      projection_stream Streams::Job

      class Projection
        extend Record

        schema do
          current_certifications Hash
        end
      end

      def init
        Projection.new(current_certifications: {})
      end

      on_message Events::DesiredCertificationCreated::V1 do |message, accumulator|
        accumulator.current_certifications[message.data.id] = message.data.master_certification_id
        accumulator
      end

      on_message Events::DesiredCertificationDestroyed::V1 do |message, accumulator|
        accumulator.current_certifications.delete(message.data.id)
        accumulator
      end
    end
  end
end
