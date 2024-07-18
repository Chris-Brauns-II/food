module Commands
  module CancelTask
    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Core::Nothing,
      metadata: Core::RequestorMetadata::V1,
      stream: Streams::Task,
      message_type: MessageTypes::Infrastructure::CANCEL_TASK,
      version: 1
    )
  end
end
