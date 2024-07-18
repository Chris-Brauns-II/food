module Seekers
  class StoriesService
    include MessageEmitter

    def initialize(seeker)
      @seeker = seeker
    end

    def create(prompt:, response:)
      message_service.create!(
        schema: Events::StoryCreated::V2,
        person_id: seeker.id,
        data: {
          id: SecureRandom.uuid,
          prompt:,
          response:
        }
      )
    end

    def update(story:, prompt:, response:)
      message_service.create!(
        schema: Events::StoryUpdated::V2,
        person_id: seeker.id,
        data: {
          id: story.id,
          prompt:,
          response:
        }
      )
    end

    def destroy(story:)
      message_service.create!(
        schema: Events::StoryDestroyed::V2,
        person_id: seeker.id,
        data: {
          id: story.id
        }
      )
    end

    private

    attr_reader :seeker
  end
end
