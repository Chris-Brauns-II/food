require 'rails_helper'

RSpec.describe MessageService do
  let(:instance) { described_class.new }
  let!(:schema) do
    Core::Schema.active(
      data: Events::SeekerViewed::Data::V1,
      metadata: Events::ApplicantStatusUpdated::MetaData::V1,
      stream: Streams::User,
      message_type:,
      version:,
      type:
    )
  end
  let(:type) { Core::EVENT }
  let(:message_type) { MessageTypes::TestingOnly::TEST_EVENT_TYPE_DONT_USE_OUTSIDE_OF_TEST }
  let(:version) { 3 }

  describe "#create_once_for_stream!" do
    subject do
      instance.create_once_for_stream!(
        id:,
        schema:,
        user_id:,
        trace_id:,
        data:,
        occurred_at:,
        metadata:
      )
    end

    let(:user_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }
    let(:data) { Events::SeekerViewed::Data::V1.new(seeker_id: SecureRandom.uuid) }
    let(:occurred_at) { DateTime.new(2000, 1, 1) }
    let(:metadata) { Events::ApplicantStatusUpdated::MetaData::V1.new(user_id: SecureRandom.uuid) }
    let(:id) { SecureRandom.uuid }

    context "when the event has not already occurred" do
      it "calls build and save!" do
        expect(instance)
          .to receive(:build)
          .with(
            schema:,
            data:,
            stream: Streams::User.new(user_id:),
            trace_id:,
            id:,
            occurred_at:,
            metadata:,
            user_id:
          )
          .and_call_original

        expect(instance)
          .to receive(:save!)
          .with(
            Message.new(
              schema:,
              data:,
              trace_id:,
              id:,
              occurred_at:,
              metadata:,
              stream: Streams::User.new(user_id:)
            )
          )
          .and_call_original

        subject
      end
    end

    context "when the event has already occured" do
      before do
        expect(described_class)
          .to receive(:stream_events)
          .with(Streams::User.new(user_id:))
          .and_return([
                        build(
                          :message,
                          schema:,
                          data: {
                            seeker_id: SecureRandom.uuid
                          },
                          metadata: {
                            user_id: SecureRandom.uuid
                          }
                        )
                      ])
      end

      it "calls build but not save!" do
        expect(instance)
          .to receive(:build)
          .with(
            schema:,
            data:,
            stream: Streams::User.new(user_id:),
            trace_id:,
            id:,
            occurred_at:,
            metadata:,
            user_id:
          )
          .and_call_original

        expect(instance)
          .not_to receive(:save!)

        subject
      end
    end
  end

  describe "#create_once_for_trace!" do
    subject do
      instance.create_once_for_trace!(
        id:,
        schema:,
        user_id:,
        trace_id:,
        data:,
        occurred_at:,
        metadata:
      )
    end

    let(:user_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }
    let(:data) { Events::SeekerViewed::Data::V1.new(seeker_id: SecureRandom.uuid) }
    let(:occurred_at) { DateTime.new(2000, 1, 1) }
    let(:metadata) { Events::ApplicantStatusUpdated::MetaData::V1.new(user_id: SecureRandom.uuid) }
    let(:id) { SecureRandom.uuid }

    context "when the event has not already occurred" do
      it "calls build and save!" do
        expect(instance)
          .to receive(:build)
          .with(
            schema:,
            data:,
            stream: Streams::User.new(user_id:),
            trace_id:,
            id:,
            occurred_at:,
            metadata:,
            user_id:
          )
          .and_call_original

        expect(instance)
          .to receive(:save!)
          .with(
            Message.new(
              schema:,
              data:,
              trace_id:,
              id:,
              occurred_at:,
              metadata:,
              stream: Streams::User.new(user_id:)
            )
          )
          .and_call_original

        subject
      end
    end

    context "when the event has already occured" do
      before do
        expect(described_class)
          .to receive(:trace_id_events)
          .with(trace_id)
          .and_return([
                        build(
                          :message,
                          schema:,
                          data: {
                            seeker_id: SecureRandom.uuid
                          },
                          metadata: {
                            user_id: SecureRandom.uuid
                          }
                        )
                      ])
      end

      it "calls build but not save!" do
        expect(instance)
          .to receive(:build)
          .with(
            schema:,
            data:,
            stream: Streams::User.new(user_id:),
            trace_id:,
            id:,
            occurred_at:,
            metadata:,
            user_id:
          )
          .and_call_original

        expect(instance)
          .not_to receive(:save!)

        subject
      end
    end
  end

  describe "#create!" do
    subject do
      instance.create!(
        id:,
        schema:,
        user_id:,
        trace_id:,
        data:,
        occurred_at:,
        metadata:
      )
    end

    let(:user_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }
    let(:data) { Events::SeekerViewed::Data::V1.new(seeker_id: SecureRandom.uuid) }
    let(:occurred_at) { DateTime.new(2000, 1, 1) }
    let(:metadata) { Events::ApplicantStatusUpdated::MetaData::V1.new(user_id: SecureRandom.uuid) }
    let(:id) { SecureRandom.uuid }

    it "calls build and save!" do
      expect(instance)
        .to receive(:build)
        .with(
          schema:,
          data:,
          stream: nil,
          trace_id:,
          id:,
          occurred_at:,
          metadata:,
          user_id:
        )
        .and_call_original

      expect(instance)
        .to receive(:save!)
        .with(
          Message.new(
            schema:,
            data:,
            trace_id:,
            id:,
            occurred_at:,
            metadata:,
            stream: Streams::User.new(user_id:)
          )
        )
        .and_call_original

      subject
    end
  end

  describe "#build" do
    subject do
      instance.build(
        id:,
        schema:,
        user_id:,
        trace_id:,
        data:,
        occurred_at:,
        metadata:
      )
    end

    let(:user_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }
    let(:data) { Events::SeekerViewed::Data::V1.new(seeker_id: SecureRandom.uuid) }
    let(:occurred_at) { DateTime.new(2000, 1, 1) }
    let(:metadata) { Events::ApplicantStatusUpdated::MetaData::V1.new(user_id: SecureRandom.uuid) }
    let(:id) { SecureRandom.uuid }

    context "when the event_schema is not a Core::Schema" do
      let(:schema) { 10 }

      it "raises a NotSchemaError" do
        expect { subject }.to raise_error(described_class::NotSchemaError)
      end
    end

    context "when event_schema is a Core::Schema" do
      context "when data doesn't type check" do
        let(:data) { "cat" }

        it "raies a InvalidSchemaError" do
          expect { subject }.to raise_error(Message::InvalidSchemaError)
        end
      end

      context "when metadata doesn't type check" do
        let(:metadata) { [1, 2, 3] }

        it "raies a InvalidSchemaError" do
          expect { subject }.to raise_error(Message::InvalidSchemaError)
        end
      end

      context "when data and metadata type check" do
        it "returns the produced message" do
          expect(subject.id).to eq(id)
          expect(subject.stream_id).to eq(user_id)
          expect(subject.schema).to eq(schema)
          expect(subject.data).to eq(data)
          expect(subject.metadata).to eq(metadata)
          expect(subject.occurred_at).to eq(occurred_at)
        end

        context "when data as a hash type checks" do
          let(:data) { { seeker_id: SecureRandom.uuid } }

          it "returns the produced message" do
            expect(subject.id).to eq(id)
            expect(subject.stream_id).to eq(user_id)
            expect(subject.schema).to eq(schema)
            expect(subject.data).to eq(Events::SeekerViewed::Data::V1.new(seeker_id: data[:seeker_id]))
            expect(subject.metadata).to eq(metadata)
            expect(subject.occurred_at).to eq(occurred_at)
          end
        end

        context "when metadata as a hash type checks" do
          let(:metadata) { { user_id: SecureRandom.uuid } }

          it "returns the produced message" do
            expect(subject.id).to eq(id)
            expect(subject.stream_id).to eq(user_id)
            expect(subject.schema).to eq(schema)
            expect(subject.data).to eq(data)
            expect(subject.metadata).to eq(Events::ApplicantStatusUpdated::MetaData::V1.new(user_id: metadata[:user_id]))
            expect(subject.occurred_at).to eq(occurred_at)
          end
        end
      end
    end
  end

  describe "#save!" do
    subject do
      instance.save!(message)
    end

    let(:message) do
      build(
        :message,
        schema:,
        stream_id: SecureRandom.uuid,
        data: {
          coach_id: SecureRandom.uuid
        }
      )
    end
    let(:schema) { Commands::AssignCoach::V2 }
    let(:schema_string) { schema.to_s }

    it "persists the message" do
      expect { subject }.to change(Event, :count).by(1)
      expect(message.id).to eq(Event.last_created.message.id)
      expect(message.stream_id).to eq(Event.last_created.message.stream_id)
      expect(message.schema).to eq(Event.last_created.message.schema)
      expect(message.data).to eq(Event.last_created.message.data)
      expect(message.metadata).to eq(Event.last_created.message.metadata)
      expect(message.occurred_at).to eq(Event.last_created.message.occurred_at)
    end

    context "enqueues messages to be published" do
      before do
        SYNC_SUBSCRIBERS.reset
        ASYNC_SUBSCRIBERS.reset

        SYNC_SUBSCRIBERS.subscribe(schema:, subscriber: sync_subscriber)
        ASYNC_SUBSCRIBERS.subscribe(schema:, subscriber: async_subscriber)
      end

      let(:sync_subscriber) { DbStreamListener.build(consumer: MessageConsumer.new, listener_name: SecureRandom.uuid) }
      let(:async_subscriber) { DbStreamListener.build(consumer: MessageConsumer.new, listener_name: SecureRandom.uuid) }

      after do
        SubscriberInitializer.run
      end

      it "queues the message to be published" do
        allow(instance)
          .to receive(:broadcast?)
          .and_return(true)

        expect(sync_subscriber)
          .to receive(:play)
          .and_call_original

        expect(ExecuteSubscriberJob)
          .to receive(:new)
          .with(subscriber_id: async_subscriber.id)
          .and_call_original

        expect(ActiveJob)
          .to receive(:perform_all_later)
          .with([be_a(ExecuteSubscriberJob)])
          .and_call_original

        subject

        instance.flush
      end
    end
  end

  describe "#flush" do
    subject { instance.flush }

    let(:user_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }
    let(:data) { { seeker_id: SecureRandom.uuid } }
    let(:occurred_at) { DateTime.new(2000, 1, 1) }
    let(:metadata) { { user_id: SecureRandom.uuid } }
    let(:id) { SecureRandom.uuid }

    let(:subscriber1) { DbStreamListener.build(consumer: MessageConsumer.new, listener_name: SecureRandom.uuid) }
    let(:subscriber2) { DbStreamListener.build(consumer: MessageConsumer.new, listener_name: SecureRandom.uuid) }

    let!(:other_schema) do
      Core::Schema.active(
        data: Events::SeekerViewed::Data::V1,
        metadata: Events::ApplicantStatusUpdated::MetaData::V1,
        stream: Streams::User,
        message_type:,
        version: 10,
        type:
      )
    end

    after do
      SubscriberInitializer.run
    end

    before do
      SYNC_SUBSCRIBERS.reset
      ASYNC_SUBSCRIBERS.reset

      SYNC_SUBSCRIBERS.subscribe(schema:, subscriber: subscriber1)
      ASYNC_SUBSCRIBERS.subscribe(schema: other_schema, subscriber: subscriber1)
      ASYNC_SUBSCRIBERS.subscribe(schema:, subscriber: subscriber2)

      allow(instance)
        .to receive(:broadcast?)
        .and_return(true)

      instance
        .create!(
          schema:,
          user_id:,
          trace_id:,
          data:,
          occurred_at:,
          metadata:
        )

      instance
        .create!(
          schema:,
          user_id:,
          trace_id:,
          data:,
          occurred_at:,
          metadata:
        )

      instance
        .create!(
          schema: other_schema,
          user_id:,
          trace_id:,
          data:,
          occurred_at:,
          metadata:
        )
    end

    it "calls pubsub" do
      expect(subscriber1)
        .to receive(:play)
        .once
        .and_call_original

      expect(subscriber2)
        .not_to receive(:play)

      expect(ExecuteSubscriberJob)
        .to receive(:new)
        .with(subscriber_id: subscriber1.id)
        .once
        .and_call_original

      expect(ExecuteSubscriberJob)
        .to receive(:new)
        .with(subscriber_id: subscriber2.id)
        .once
        .and_call_original

      expect(ActiveJob)
        .to receive(:perform_all_later)
        .with([be_a(ExecuteSubscriberJob), be_a(ExecuteSubscriberJob)])
        .and_call_original

      subject
    end
  end

  describe ".register" do
    subject do
      described_class.register(schema:)
    end

    context "passed something other than a Event::Schema" do
      let(:schema) { { not: "a schema" } }

      it "raises a NotSchemaError" do
        expect { subject }.to raise_error(described_class::NotSchemaError)
      end
    end

    context "when passed an existing registered schema" do
      let(:schema) { Events::UserCreated::V1 }

      it "raises a SchemaAlreadyDefinedError" do
        expect { subject }.to raise_error(described_class::SchemaAlreadyDefinedError)
      end
    end

    context "when passed a 2nd active schema for the same message type" do
      it "raise a MessageTypeHasMultipleActiveSchemas" do
        expect do
          Core::Schema.active(
            data: Core::Nothing,
            metadata: Core::Nothing,
            stream: Streams::User,
            message_type: MessageTypes::User::USER_CREATED,
            type: Core::EVENT,
            version: 2
          )
        end.to raise_error(described_class::MessageTypeHasMultipleActiveSchemas)
      end
    end
  end

  describe ".all_schemas" do
    subject { described_class.all_schemas }

    it "returns all registered schemas" do
      expect(subject).to include(schema)
    end
  end

  describe ".all_messages" do
    before do
      Event.from_message!(message1)
      Event.from_message!(message2)
      Event.from_message!(message3)
    end

    let(:message1) do
      build(
        :message,
        schema: Events::TaskExecuted::V1
      )
    end
    let(:message2) do
      build(
        :message,
        schema: Events::TaskExecuted::V1
      )
    end
    let(:message3) do
      build(
        :message,
        schema: Events::SessionStarted::V1
      )
    end

    context "when schema is a schema" do
      it "returns all the messages persisted for a schema" do
        expect(described_class.all_messages(Events::TaskExecuted::V1)).to contain_exactly(message1, message2)
      end
    end

    context "when schema is not a schema" do
      it "raises a NotSchemaError" do
        expect { expect(described_class.all_messages(10)) }.to raise_error(described_class::NotSchemaError)
      end
    end
  end

  describe ".stream_events" do
    before do
      Event.from_message!(message1)
      Event.from_message!(message2)
      Event.from_message!(message3)
    end

    let(:message_id) { SecureRandom.uuid }
    let(:message1) do
      build(
        :message,
        stream_id: message_id,
        schema: Events::MessageSent::V1,
        data: Core::Nothing,
        occurred_at: Time.zone.local(2021, 1, 1)
      )
    end
    let(:message2) do
      build(
        :message,
        stream_id: message_id,
        schema: Events::SlackMessageSent::V2,
        data: {
          channel: "#cool",
          blocks: [
            {
              type: "header",
              text: "Sup!",
              emoji: true
            }
          ]
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end
    let(:message3) do
      build(
        :message,
        stream_id: message_id,
        schema: Commands::SendSlackMessage::V2,
        data: {
          channel: "#cool",
          text: "Sup"
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end

    context "when stream is a Stream" do
      it "returns all the events for the stream in order" do
        expect(described_class.stream_events(Streams::Message.new(message_id:))).to eq([message2, message1])
      end
    end

    context "when stream is not a Stream" do
      it "raises a NotSchemaError" do
        expect { described_class.stream_events("cat") }.to raise_error(described_class::NotStreamError)
      end
    end
  end

  describe ".trace_id_events" do
    before do
      Event.from_message!(message1)
      Event.from_message!(message2)
      Event.from_message!(message3)
    end

    let(:trace_id) { SecureRandom.uuid }
    let(:message1) do
      build(
        :message,
        trace_id:,
        schema: Events::MessageSent::V1,
        data: Core::Nothing,
        occurred_at: Time.zone.local(2021, 1, 1)
      )
    end
    let(:message2) do
      build(
        :message,
        trace_id:,
        schema: Events::SlackMessageSent::V2,
        data: {
          channel: "#cool",
          blocks: [
            {
              type: "header",
              text: "Sup!",
              emoji: true
            }
          ]
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end
    let(:message3) do
      build(
        :message,
        trace_id:,
        schema: Commands::SendSlackMessage::V2,
        data: {
          channel: "#cool",
          text: "Sup"
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end

    context "when trace_id is a string" do
      it "returns all the events for the trace_id in order" do
        expect(described_class.trace_id_events(trace_id)).to eq([message2, message1])
      end
    end

    context "when trace_id is not a string" do
      it "raises a NotSchemaError" do
        expect { described_class.trace_id_events(5) }.to raise_error(described_class::NotTraceIdError)
      end
    end
  end

  describe ".get_schema" do
    subject do
      described_class.get_schema(message_type:, version:)
    end

    context "when the schema does not exist" do
      it "raises a SchemaNotFoundError" do
        expect { described_class.get_schema(message_type: "not_a_real_event", version:) }.to raise_error(described_class::SchemaNotFoundError)
      end
    end

    context "when the schema exists" do
      it "returns the schema" do
        expect(described_class.get_schema(message_type:, version:)).to eq(schema)
      end
    end
  end

  describe ".migrate_event" do
    let(:schema) { Events::UserCreated::V1 }

    let!(:message1) do
      Message.new(
        id: SecureRandom.uuid,
        stream: Streams::User.new(user_id: SecureRandom.uuid),
        trace_id: SecureRandom.uuid,
        schema:,
        occurred_at: Time.zone.parse('2000-1-1'),
        data: Events::UserCreated::Data::V1.new(first_name: "John"),
        metadata: Core::Nothing
      )
    end
    let!(:message2) do
      Message.new(
        id: SecureRandom.uuid,
        stream: Streams::User.new(user_id: SecureRandom.uuid),
        trace_id: SecureRandom.uuid,
        schema:,
        occurred_at: Time.zone.parse('2000-1-1'),
        data: Events::UserCreated::Data::V1.new(first_name: "Chris"),
        metadata: Core::Nothing
      )
    end
    let!(:event1) { Event.from_message!(message1) }
    let!(:event2) { Event.from_message!(message2) }

    it "passes each message for the schema to the provided block" do
      described_class.migrate_event(schema:) do |message|
        expect([message1, message2]).to include(message)
      end
    end
  end
end
