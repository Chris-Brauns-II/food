module Jobs
  module Projectors
    class CareerPaths < Projector
      projection_stream Streams::Job

      class Path
        extend Record

        schema do
          id String
          title String
          lower_limit String
          upper_limit String
          order Integer
        end

        attr_writer :order
      end

      class Projection
        extend Record

        schema do
          paths ArrayOf(Path)
        end
      end

      def init
        Projection.new(paths: [])
      end

      on_message Events::CareerPathCreated::V1 do |message, accumulator|
        accumulator.with(
          paths: accumulator.paths + [Path.new(
            id: message.data.id,
            title: message.data.title,
            lower_limit: message.data.lower_limit,
            upper_limit: message.data.upper_limit,
            order: message.data.order
          )]
        )
      end

      on_message Events::CareerPathUpdated::V1 do |message, accumulator|
        updated_path = accumulator.paths.find { |path| path.id == message.data.id }

        updated_path.order = message.data.order

        accumulator.with(
          paths: accumulator.paths
        )
      end

      on_message Events::CareerPathDestroyed::V1 do |message, accumulator|
        accumulator.with(
          paths: accumulator.paths.reject { |path| path.id == message.data.id }
        )
      end
    end
  end
end
