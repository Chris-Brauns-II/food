RSpec.shared_context "command emitter" do |flush|
  around do |ex|
    flush = true if flush.nil?

    message_service = MessageService.new

    Thread.current.thread_variable_set(:message_service, message_service)

    ex.run

    message_service.flush if flush

    Thread.current.thread_variable_set(:message_service, nil)
  end
end
