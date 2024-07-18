module Jobs
  module Projectors
    class Attributes < Projector
      projection_stream Streams::Job

      class Attribute
        extend Record

        schema do
          name String
          id Uuid
          acceptible_set ArrayOf(String)
        end
      end

      class Projection
        extend Record

        schema do
          attributes HashOf(Uuid => Attribute)
        end
      end

      def init
        Projection.new(attributes: {})
      end

      on_message Events::JobAttributeCreated::V1 do |message, accumulator|
        accumulator.attributes[message.data.id] = Attribute.new(
          name: message.data.attribute_name,
          id: message.data.attribute_id,
          acceptible_set: message.data.acceptible_set
        )
        accumulator
      end

      on_message Events::JobAttributeUpdated::V1 do |message, accumulator|
        accumulator.attributes[message.data.id] = accumulator.attributes[message.data.id].with(
          acceptible_set: message.data.acceptible_set
        )
        accumulator
      end

      on_message Events::JobAttributeDestroyed::V1 do |message, accumulator|
        accumulator.attributes.delete(message.data.id)
        accumulator
      end
    end
  end
end
