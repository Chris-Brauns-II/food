require 'rails_helper'

RSpec.describe Message do
  describe "#initialize" do
    context "when missing a required key" do
      it "raises a ValueSemantics::MissingAttributes error" do
        expect do
          described_class.new(
            id: SecureRandom.uuid,
            stream: Streams::Job.new(job_id: SecureRandom.uuid),
            trace_id: SecureRandom.uuid,
            schema: Events::ApplicantStatusUpdated::V1,
            metadata: {},
            occurred_at: Time.zone.now
          )
        end.to raise_error(ValueSemantics::MissingAttributes)
      end
    end

    context "when a key is of the wrong type" do
      it "raises a ValueSemantics::InvalidValue error" do
        expect do
          described_class.new(
            id: SecureRandom.uuid,
            trace_id: SecureRandom.uuid,
            stream: 10,
            schema: Events::ApplicantStatusUpdated::V1,
            metadata: {},
            data: {},
            occurred_at: Time.zone.now
          )
        end.to raise_error(ValueSemantics::InvalidValue)
      end
    end

    describe "#occurred_at" do
      let(:message) do
        build(
          :message,
          schema: Events::DayElapsed::V2,
          data: {
            date: Date.new(2000, 1, 1),
            day_of_week: Events::DayElapsed::Data::DaysOfWeek::WEDNESDAY
          },
          occurred_at:
        )
      end

      context "when passed a Time for occurred_at" do
        let(:occurred_at) { Time.new(2000, 1, 1, 0, 0, 0, "+00:00") }

        it "converts it to ActiveSupport::TimeWithZone" do
          expect(message.occurred_at).to eq(Time.zone.parse('2000-01-01 00:00:00 UTC'))
        end
      end

      context "when passed a DateTime for occurred_at" do
        let(:occurred_at) { DateTime.new(2000, 1, 1, 0, 0, 0) }

        it "converts it to ActiveSupport::TimeWithZone" do
          expect(message.occurred_at).to eq(Time.zone.parse('2000-01-01 00:00:00 UTC'))
        end
      end

      context "when passed a formatted string string for occurred_at" do
        let(:occurred_at) { "2000-01-01 00:00:00 UTC" }

        it "converts it to ActiveSupport::TimeWithZone" do
          expect(message.occurred_at).to eq(Time.zone.parse('2000-01-01 00:00:00 UTC'))
        end
      end

      context "when passed something else" do
        it "converts it to ActiveSupport::TimeWithZone" do
          expect { build(:message, occurred_at: "Cat o'clock") }.to raise_error(ValueSemantics::InvalidValue)
        end
      end
    end
  end

  describe "#serialize" do
    let(:message) do
      build(
        :message,
        schema: Events::JobSearch::V2,
        data: {
          search_terms: "Some Search",
          industries: nil,
          tags: %w[Great Tags]
        },
        metadata: {
          source: "seeker",
          id: SecureRandom.uuid,
          utm_source: "google"
        },
        occurred_at: Time.zone.local(2000, 1, 1)
      )
    end

    it "converts the message to a hash" do
      expect(message.serialize).to eq(
        {
          id: message.id,
          trace_id: message.trace_id,
          schema: {
            message_type: MessageTypes::JobSearch::JOB_SEARCH,
            version: 2
          },
          stream: message.stream.id,
          data: {
            search_terms: "Some Search",
            industries: nil,
            tags: %w[Great Tags]
          },
          metadata: {
            source: "seeker",
            id: message.metadata.id,
            utm_source: "google"
          },
          occurred_at: "2000-01-01 00:00:00.000000000 +0000"
        }
      )
    end
  end

  describe ".deserialize" do
    let(:serilized_message) do
      {
        id: SecureRandom.uuid,
        trace_id: SecureRandom.uuid,
        schema: {
          message_type: MessageTypes::JobSearch::JOB_SEARCH,
          version: 2
        },
        stream: SecureRandom.uuid,
        data: {
          search_terms: "Some Search",
          industries: nil,
          tags: %w[Great Tags]
        },
        metadata: {
          source: "seeker",
          id: SecureRandom.uuid,
          utm_source: "google"
        },
        occurred_at: "2000-01-01 00:00:00.000000000 +0000"
      }
    end

    it "converts the message to a hash" do
      expect(described_class.deserialize(serilized_message)).to eq(
        Message.new(
          id: serilized_message[:id],
          trace_id: serilized_message[:trace_id],
          schema: Events::JobSearch::V2,
          stream: Streams::Search.new(search_id: serilized_message[:stream]),
          data: Events::JobSearch::Data::V1.new(
            search_terms: "Some Search",
            industries: nil,
            tags: %w[Great Tags]
          ),
          metadata: Events::JobSearch::MetaData::V2.new(
            source: "seeker",
            id: serilized_message[:metadata][:id],
            utm_source: "google"
          ),
          occurred_at: Time.zone.local(2000, 1, 1)
        )
      )
    end
  end
end
