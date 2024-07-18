module Events
  module TestimonialCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          job_id Uuid
          name String
          title String
          testimonial String
          photo_url String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::TESTIMONIAL_CREATED,
      version: 1
    )
  end
end
