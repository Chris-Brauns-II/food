module Users
  class UsersReactor < MessageReactor
    def can_replay?
      true
    end

    on_message Events::RoleAdded::V2 do |message|
      return unless message.data.role == Role::Types::COACH

      user_created = Projectors::Streams::GetFirst.project(
        stream: message.stream,
        schema: Events::UserCreated::V1
      )

      return if user_created&.data&.email.nil?

      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        schema: Events::CoachAdded::V1,
        user_id: message.stream.id,
        data: {
          coach_id: SecureRandom.uuid,
          email: user_created.data.email
        }
      )
    end
  end
end
