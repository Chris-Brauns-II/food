require 'rails_helper'

RSpec.describe PlayStreamJob do
  let(:listener) { DbStreamListener.build(consumer:, listener_name:) }
  let(:consumer) { double(:consumer, can_replay?: true, handle_message: nil, :message_service= => nil) }
  let(:listener_name) { SecureRandom.uuid }

  it "plays the stream" do
    expect(listener)
      .to receive(:play)

    described_class.new.perform(listener_name:)
  end
end
