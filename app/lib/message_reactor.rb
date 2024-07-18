class MessageReactor < MessageConsumer
  def initialize(message_service: MessageService.new)
    super()
    @message_service = message_service
  end

  delegate :flush, to: :message_service

  attr_reader :message_service

  def reset_for_replay; end

  def can_replay?
    false
  end
end
