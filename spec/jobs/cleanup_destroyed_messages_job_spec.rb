require 'rails_helper'

RSpec.describe CleanupDestroyedMessagesJob do
  let(:schema1) do
    Core::Schema.destroy!(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::TestingOnly::TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST,
      version: 1
    )
  end
  let(:schema2) do
    Core::Schema.active(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::TestingOnly::TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST,
      version: 2
    )
  end
  let!(:event1) do
    Event.create!(
      event_type: schema1.message_type,
      version: schema1.version,
      data: {},
      metadata: {},
      aggregate_id: SecureRandom.uuid,
      trace_id: SecureRandom.uuid
    )
  end
  let!(:event2) do
    Event.create!(
      event_type: schema2.message_type,
      version: schema2.version,
      data: {},
      metadata: {},
      aggregate_id: SecureRandom.uuid,
      trace_id: SecureRandom.uuid
    )
  end

  it "creates a day elapse event" do
    expect(MessageService)
      .to receive(:all_schemas)
      .and_return([
                    schema1,
                    schema2
                  ])

    described_class.new.perform

    expect(Event.find_by(id: event1.id)).to eq(nil)
    expect(Event.find_by(id: event2.id)).to eq(event2)
  end
end
