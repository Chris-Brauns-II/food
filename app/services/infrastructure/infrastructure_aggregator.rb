module Infrastructure
  class InfrastructureAggregator < MessageConsumer
    def reset_for_replay
      Task.delete_all
    end

    on_message Events::TaskScheduled::V1, :sync do |message|
      Infrastructure::Task.create!(
        id: message.stream.task_id,
        execute_at: message.data.execute_at,
        command: message.data.command,
        state: Infrastructure::TaskStates::ENQUEUED
      )
    end

    on_message Events::TaskExecuted::V1, :sync do |message|
      task = Infrastructure::Task.find(message.stream.task_id)
      task.execute!
    end

    on_message Events::TaskCancelled::V1, :sync do |message|
      task = Infrastructure::Task.find(message.stream.task_id)
      task.cancel!
    end
  end
end
