require 'rails_helper'

RSpec.describe Event do
  describe "#message" do
    subject { event.message }

    let(:id) { SecureRandom.uuid }
    let(:event) do
      build(
        :event,
        version: Events::JobSearch::V1.version,
        event_type: Events::JobSearch::V1.message_type,
        data: {
          search_terms: "Cool job",
          tags: nil,
          industries: ['Red Industry', 'Lame Industry']
        },
        metadata: {
          source: "seeker",
          id:
        }
      )
    end

    it "creates an Message with the same data" do
      expect(subject).to be_a(Message)

      expect(subject.id).to eq(event[:id])
      expect(subject.trace_id).to eq(event[:trace_id])
      expect(subject.stream_id).to eq(event[:aggregate_id])
      expect(subject.schema.message_type).to eq(event[:event_type])
      expect(subject.data).to eq(Events::JobSearch::Data::V1.new(
                                   search_terms: "Cool job",
                                   tags: nil,
                                   industries: ['Red Industry', 'Lame Industry']
                                 ))
      expect(subject.metadata).to eq(Events::JobSearch::MetaData::V1.new(
                                       id:,
                                       source: "seeker"
                                     ))
      expect(subject.schema.version).to eq(event[:version])
      expect(subject.occurred_at).to eq(event[:occurred_at])
    end
  end

  describe ".from_message!" do
    subject { described_class.from_message!(message) }

    let(:id) { SecureRandom.uuid }
    let(:message) do
      build(
        :message,
        schema: Events::JobSearch::V2,
        data: {
          search_terms: "Cool job",
          tags: nil,
          industries: ['Red Industry', 'Lame Industry']
        },
        metadata: {
          id:,
          source: "seeker",
          utm_source: "www.google.com"
        }
      )
    end

    it "creates an Message with the same data" do
      expect(subject).to be_a(described_class)

      expect(subject[:id]).to eq(message.id)
      expect(subject[:aggregate_id]).to eq(message.stream_id)
      expect(subject[:trace_id]).to eq(message.trace_id)
      expect(subject[:event_type]).to eq(message.schema.message_type)
      expect(subject[:data].deep_symbolize_keys).to eq({
                                                         search_terms: "Cool job",
                                                         tags: nil,
                                                         industries: ['Red Industry', 'Lame Industry']
                                                       })
      expect(subject[:metadata].deep_symbolize_keys).to eq({
                                                             source: "seeker",
                                                             id:,
                                                             utm_source: "www.google.com"
                                                           })
      expect(subject[:version]).to eq(message.schema.version)
      expect(subject[:occurred_at]).to eq(message.occurred_at)
    end
  end
end
