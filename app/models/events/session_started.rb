module Events
  module SessionStarted
    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::SESSION_STARTED,
      version: 1
    )
  end
end
