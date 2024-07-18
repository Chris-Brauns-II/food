module People
  module Projectors
    class Email < Projector
      projection_stream Streams::Person

      class Projection
        extend Record

        schema do
          initial_email Either(String, nil)
          current_email Either(String, nil)
        end
      end

      def init
        Projection.new(
          initial_email: nil,
          current_email: nil
        )
      end

      on_message Events::PersonAdded::V1 do |message, accumulator|
        accumulator.with(
          initial_email: message.data.email,
          current_email: message.data.email
        )
      end

      on_message Events::BasicInfoAdded::V1 do |message, accumulator|
        accumulator = accumulator.with(initial_email: message.data.email) if accumulator.initial_email.blank?
        accumulator.with(current_email: message.data.email)
      end
    end
  end
end
