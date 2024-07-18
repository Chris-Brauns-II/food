class ExecuteTasksJob < ApplicationJob
  queue_as :default

  include MessageEmitter

  def perform
    with_message_service do
      Infrastructure::Task.ready_to_execute.each do |task|
        command = task.command
        schema = command.schema

        message_service.create!(
          **{
            schema:,
            data: command.data,
            trace_id: command.trace_id,
            id: command.id,
            metadata: command.metadata,
            schema.stream.id => command.stream.id
          }
        )

        message_service.create!(
          schema: Events::TaskExecuted::V1,
          data: Core::Nothing,
          trace_id: command.trace_id,
          task_id: task.id
        )
      end
    end
  end
end
