module Employers
  module Projectors
    class Name < Projector
      projection_stream Streams::Employer

      class Projection
        extend Record

        schema do
          name Either(String, nil)
        end
      end

      def init
        Projection.new(
          name: nil
        )
      end

      on_message Events::EmployerCreated::V1 do |message, accumulator|
        accumulator.with(name: message.data.name)
      end

      on_message Events::EmployerUpdated::V1 do |message, accumulator|
        accumulator.with(name: message.data.name)
      end
    end
  end
end
