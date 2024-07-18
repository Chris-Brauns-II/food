module People
  module Projectors
    class BasicInfo < Projector
      projection_stream Streams::Person

      class Projection
        extend Record

        schema do
          first_name Either(String, nil)
          last_name Either(String, nil)
          email Either(String, nil)
          phone_number Either(String, nil)
        end
      end

      def init
        Projection.new(
          first_name: nil,
          last_name: nil,
          email: nil,
          phone_number: nil
        )
      end

      on_message Events::PersonAdded::V1 do |message, accumulator|
        accumulator.with(
          first_name: message.data.first_name,
          last_name: message.data.last_name,
          email: message.data.email,
          phone_number: message.data.phone_number
        )
      end

      on_message Events::BasicInfoAdded::V1 do |message, accumulator|
        accumulator.with(
          first_name: message.data.first_name,
          last_name: message.data.last_name,
          email: message.data.email,
          phone_number: message.data.phone_number
        )
      end
    end
  end
end
