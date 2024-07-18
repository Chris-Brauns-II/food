RSpec::Matchers.define :raise_consumer_error do |expected_error_class, expected_message|
  supports_block_expectations

  match do |actual|
    actual.call
    false
  rescue MessageConsumer::FailedToHandleMessage => e
    @raised_error = e
    @raised_error.cause.is_a?(expected_error_class) && @raised_error.erroring_message == expected_message
  else
    false
  end

  failure_message do |_|
    if @raised_error
      "expected message consumer wrapped #{expected_error_class} with message '#{expected_message.serialize}', but got #{@raised_error.cause} with message '#{@raised_error.erroring_message}'"
    else
      "expected message consumer wrapped #{expected_error_class} with message '#{expected_message.serialize}', but no error was raised"
    end
  end

  failure_message_when_negated do |_actual|
    "expected no #{expected_error} with message '#{expected_message.serialize}', but an error was raised"
  end

  description do
    "raise message consumer wrapped #{expected_error_class} with message '#{expected_message.serialize}'"
  end
end
