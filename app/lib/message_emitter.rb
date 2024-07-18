module MessageEmitter
  private

  def with_message_service(message_service = MessageService.new)
    Thread.current.thread_variable_set(:message_service, message_service)
    yield
  ensure
    message_service.flush

    Thread.current.thread_variable_set(:message_service, nil)
  end

  def message_service
    Thread.current.thread_variable_get(:message_service)
  end
end
