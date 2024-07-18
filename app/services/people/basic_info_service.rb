module People
  class BasicInfoService
    def initialize(user_id, message_service)
      @user = User.find(user_id)
      @message_service = message_service
    end

    def update(about:, first_name:, last_name:, phone_number:, email:, zip_code:) # rubocop:disable Metrics/ParameterLists
      seeker = user.seeker
      return unless seeker

      stream = Streams::Person.new(person_id: seeker.id)

      message_service.create!(
        schema: Events::BasicInfoAdded::V1,
        stream:,
        data: {
          first_name:,
          last_name:,
          phone_number:,
          email:
        }
      )

      message_service.create!(
        schema: Events::ZipAdded::V2,
        stream:,
        data: {
          zip_code:
        }
      )

      message_service.create!(
        schema: Events::PersonAboutAdded::V1,
        stream:,
        data: {
          about:
        }
      )
    end

    private

    attr_reader :user, :message_service
  end
end
