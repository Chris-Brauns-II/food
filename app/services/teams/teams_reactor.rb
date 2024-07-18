module Teams
  class TeamsReactor < MessageReactor
    def can_replay?
      true
    end

    on_message Commands::Add::V1 do |message|
      return if Events::Added::V1.all_messages.any? { |m| m.data.name == message.data.name }

      message_service.create_once_for_stream!(
        stream: message.stream,
        trace_id: message.trace_id,
        schema: Events::Added::V1,
        data: {
          name: message.data.name
        }
      )
    end

    # This should maybe be owned by the contact system.
    # I'm currently unsure on this placement
    on_message Commands::AddPrimarySlackChannel::V1 do |message|
      message_service.create_once_for_trace!(
        stream: message.stream,
        trace_id: message.trace_id,
        schema: Events::PrimarySlackChannelAdded::V1,
        data: {
          channel: message.data.channel
        }
      )
    end

    # This should maybe be owned by the contact system.
    # I'm currently unsure on this placement
    on_message Commands::SendSlackMessage::V2 do |message|
      slack_channel = ::Projectors::Streams::GetLast.project(
        schema: Events::PrimarySlackChannelAdded::V1,
        stream: message.stream
      )

      return if slack_channel.nil?

      message_service.create_once_for_trace!(
        message_id: SecureRandom.uuid,
        trace_id: message.trace_id,
        schema: ::Commands::SendSlackMessage::V2,
        data: {
          text: message.data.text,
          channel: slack_channel.data.channel,
          blocks: message.data.blocks
        }
      )
    end

    on_message Commands::AddUserToTeam::V1 do |message|
      messages = MessageService.stream_events(message.stream)
      team = Projectors::TeamMembers.new.project(messages).team

      return if team.include?(message.data.user_id)

      message_service.create_once_for_trace!(
        stream: message.stream,
        trace_id: message.trace_id,
        schema: Events::UserAddedToTeam::V1,
        data: {
          user_id: message.data.user_id
        }
      )
    end

    on_message Commands::RemoveUserFromTeam::V1 do |message|
      messages = MessageService.stream_events(message.stream)
      team = Projectors::TeamMembers.new.project(messages).team

      return unless team.include?(message.data.user_id)

      message_service.create_once_for_trace!(
        stream: message.stream,
        trace_id: message.trace_id,
        schema: Events::UserRemovedFromTeam::V1,
        data: {
          user_id: message.data.user_id
        }
      )
    end
  end
end
