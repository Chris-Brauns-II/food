require 'rails_helper'

RSpec.describe SubscriberRegistry do
  describe "#subscribe" do
    subject do
      registry.subscribe(schema:, subscriber:)
    end

    let(:registry) { described_class.new }
    let(:schema) { Events::SessionStarted::V1 }

    context "when subscriber is not a stream listener" do
      let(:subscriber) { ["cat"] }

      it "raises a NotStreamListenerError" do
        expect { subject }.to raise_error(described_class::NotStreamListenerError)
      end
    end

    context "when subscriber is a stream listener" do
      let(:subscriber) { DbStreamListener.build(consumer: MessageConsumer.new, listener_name:) }
      let(:listener_name) { SecureRandom.uuid }

      it "allows the subscriber to be retried by id" do
        subject

        expect(registry.get_subscriber(subscriber_id: subscriber.id)).to eq(subscriber)
      end

      it "allows the subscriber to be retrieved by schema string" do
        subject

        expect(registry.get_subscribers_for_schema(schema_string: schema.to_s)).to eq([subscriber])
      end
    end
  end
end
