module Events
  module TaskCancelled
    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::RequestorMetadata::V1,
      stream: Streams::Task,
      message_type: MessageTypes::Infrastructure::TASK_CANCELLED,
      version: 1
    )
  end
end
