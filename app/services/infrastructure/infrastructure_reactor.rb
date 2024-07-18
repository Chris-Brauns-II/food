module Infrastructure
  class InfrastructureReactor < MessageReactor
    on_message Commands::ScheduleTask::V1, :sync do |message|
      task = Infrastructure::Task.find_by(id: message.stream.task_id)
      return if task.present?

      message_service.create!(
        schema: Events::TaskScheduled::V1,
        trace_id: message.trace_id,
        task_id: message.stream.task_id,
        data: {
          execute_at: message.data.execute_at,
          command: message.data.command
        },
        metadata: {
          requestor_type: message.metadata.requestor_type,
          requestor_id: message.metadata.requestor_id
        }
      )
    end

    on_message Commands::CancelTask::V1, :sync do |message|
      task = Infrastructure::Task.find_by(id: message.stream.task_id)
      return if task.blank?
      return if task.state != Infrastructure::TaskStates::ENQUEUED

      message_service.create!(
        schema: Events::TaskCancelled::V1,
        trace_id: message.trace_id,
        task_id: message.stream.task_id,
        data: Core::Nothing,
        metadata: {
          requestor_type: message.metadata.requestor_type,
          requestor_id: message.metadata.requestor_id
        }
      )
    end
  end
end
