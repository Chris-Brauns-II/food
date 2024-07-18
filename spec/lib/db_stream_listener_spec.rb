require 'rails_helper'

RSpec.describe DbStreamListener do
  let(:consumer) { MessageConsumer.new }

  let!(:event) { create(:event, schema: Events::UserCreated::V1, occurred_at: event_occurred_at) }
  let!(:event2) { create(:event, schema: Events::UserCreated::V1, occurred_at: event_occurred_at + 2.days) }

  let(:event_occurred_at) { Date.new(2020, 1, 1) }
  let(:instance) { described_class.build(consumer:, listener_name: "listener_name", now:, stride:) }
  let(:stride) { 500 }
  let(:now) { Time.zone.now }

  describe "#play" do
    subject { instance.play }

    context "when the first event raises an error" do
      let(:now) { Time.zone.local(2019, 1, 1) }

      it "does not update the bookmark" do
        expect(consumer).to receive(:handle_message).with(
          event.message
        ).and_raise(StandardError)

        expect { subject }.to raise_error(StandardError)

        expect(ListenerBookmark.find_by(consumer_name: "listener_name").event_id).to eq(described_class::DEFAULT_EVENT_ID)
      end
    end

    context "when the second event raises an error" do
      let(:now) { Time.zone.local(2019, 1, 1) }

      it "updates the bookmark" do
        expect(consumer).to receive(:handle_message).with(
          event.message
        )

        expect(consumer).to receive(:handle_message).with(
          event2.message
        ).and_raise(StandardError)

        expect { subject }.to raise_error(StandardError)

        expect(ListenerBookmark.find_by(consumer_name: "listener_name").event_id).to eq(described_class::DEFAULT_EVENT_ID)
      end
    end

    context "when we need to process events in multiple passes" do
      let(:stride) { 1 }

      it "plays all events" do
        expect(consumer).to receive(:handle_message).with(
          event.message
        )

        expect(consumer).to receive(:handle_message).with(
          event2.message
        )

        subject

        # expect(ListenerBookmark.find_by(consumer_name: "listener_name").event_id).to eq(event2.id)
      end
    end

    context "when there is a bookmark" do
      before do
        create(
          :listener_bookmark,
          consumer_name: "listener_name",
          current_timestamp: bookmark_event.message.occurred_at,
          event_id: bookmark_event.id
        )
      end

      let(:bookmark_event) { event }

      context "with a second event at the bookmark" do
        # Hardcoding to the maximum possible uuid value so that it's guaranteed to be after the bookmark according to
        # ordering of uuids
        let!(:same_time_event) { create(:event, schema: Events::UserCreated::V1, id: "ffffffff-ffff-ffff-ffff-ffffffffffff", occurred_at: event_occurred_at) }

        it "consumes the events after the bookmark" do
          expect(consumer).to receive(:handle_message).with(
            same_time_event.message
          )

          expect(consumer).to receive(:handle_message).with(
            event2.message
          )

          expect(consumer).not_to receive(:handle_message).with(
            event.message
          )

          subject
        end
      end

      it "consumes the events after the bookmark" do
        expect(consumer).to receive(:handle_message).with(
          event2.message
        )

        expect(consumer).not_to receive(:handle_message).with(
          event.message
        )

        subject
      end

      context "when the bookmark is on the last event" do
        let(:bookmark_event) { event2 }

        it "does not update the bookmark" do
          expect { subject }.not_to(change { ListenerBookmark.find_by(consumer_name: "listener_name").event_id })
        end
      end
    end

    context 'when there is not a bookmark' do
      context "when the consumer is replayable" do
        before do
          allow(consumer)
            .to receive(:can_replay?)
            .and_return(true)
        end

        context "when now is before the events" do
          let(:now) { Time.zone.local(2019, 1, 1) }

          it "creates a bookmark and calls the consumer" do
            expect(consumer)
              .to receive(:handle_message)
              .with(be_a(Message)).twice

            expect { subject }.to change {
              ListenerBookmark.find_by(consumer_name: "listener_name")&.event_id
            }.from(nil).to(event2.id)
          end
        end

        context "when now is after the events" do
          let(:now) { Time.zone.local(2021, 1, 1) }

          it "creates a bookmark and calls the consumer" do
            expect(consumer)
              .to receive(:handle_message)
              .with(be_a(Message)).twice

            expect { subject }.to change {
              ListenerBookmark.find_by(consumer_name: "listener_name")&.event_id
            }.from(nil).to(event2.id)
          end
        end
      end

      context "when the consumer is not replayable" do
        before do
          allow(consumer)
            .to receive(:can_replay?)
            .and_return(false)
        end

        context "when now is before the events" do
          let(:now) { Time.zone.local(2019, 1, 1) }

          it "creates a bookmark and calls the consumer" do
            expect(consumer)
              .to receive(:handle_message)
              .with(be_a(Message)).twice

            expect { subject }.to change {
              ListenerBookmark.find_by(consumer_name: "listener_name")&.event_id
            }.from(nil).to(event2.id)
          end
        end

        context "when now is after the events" do
          let(:now) { Time.zone.local(2021, 1, 1) }

          it "does not updates the bookmark or call the consumer" do
            expect(consumer).not_to receive(:handle_message)

            expect { subject }
              .to change { ListenerBookmark.find_by(consumer_name: "listener_name")&.event_id }
              .from(nil)
              .to(described_class::DEFAULT_EVENT_ID)
          end
        end
      end
    end
  end

  describe "#replay" do
    subject { instance.replay }

    context "when the consumer can be replayed" do
      before do
        expect(consumer)
          .to receive(:can_replay?)
          .and_return(true)
          .twice
      end

      it "doesn't play the stream or reset for replay" do
        expect(instance)
          .to receive(:play)

        expect(consumer).to receive(:reset_for_replay)

        subject
      end
    end

    context "when the consumer can't be replayed" do
      before do
        expect(consumer)
          .to receive(:can_replay?)
          .and_return(false)
          .twice
      end

      it "doesn't play the stream or reset for replay" do
        expect(instance)
          .not_to receive(:play)

        expect(consumer).not_to receive(:reset_for_replay)

        subject
      end
    end
  end

  describe ".get_listener" do
    it "retrieves a listener if created" do
      described_class.build(consumer:, listener_name: "example")

      expect(StreamListener.get_listener("example")).to be_a(described_class)
      expect(StreamListener.get_listener(SecureRandom.uuid)).to eq(nil)
    end
  end
end
