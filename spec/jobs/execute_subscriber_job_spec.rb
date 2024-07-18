require 'rails_helper'

RSpec.describe ExecuteSubscriberJob do
  let(:subscriber) { double(:subscriber, play: nil) }

  it "calls ASYNC_SUBSCRIBERS execute_event" do
    expect(ASYNC_SUBSCRIBERS)
      .to receive(:get_subscriber)
      .with(subscriber_id: "a class")
      .and_return(subscriber)

    expect(subscriber).to receive(:play)

    described_class.new.perform(subscriber_id: "a class")
  end
end
