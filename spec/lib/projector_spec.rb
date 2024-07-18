require 'rails_helper'

RSpec.describe Projector do
  describe ".on_message" do
    context "when no stream is given" do
      let(:sub_klass) do
        Class.new(described_class) do
          on_message Events::SessionStarted::V1 do |_|
            true
          end
        end
      end

      it "raises a NoStreamError" do
        expect { sub_klass }.to raise_error(described_class::NoStreamError)
      end
    end

    context "when the stream and on_message stream don't align" do
      let(:sub_klass) do
        Class.new(described_class) do
          projection_stream Streams::Coach

          on_message Events::SessionStarted::V1 do |_|
            true
          end
        end
      end

      it "raises a NotCorrectStreamError" do
        expect { sub_klass }.to raise_error(described_class::NotCorrectStreamError)
      end
    end
  end

  describe "#project" do
    context "when called without an init method" do
      let(:sub_klass) do
        Class.new(described_class) do
          projection_stream Streams::User
        end
      end

      it "raises a WrongAggregatorError" do
        expect { sub_klass.new.project([]) }.to raise_error(NoMethodError)
      end
    end

    context "when the reduces changes the accumulation type" do
      let(:sub_klass) do
        Class.new(described_class) do
          projection_stream Streams::User

          def init
            10
          end

          on_message Events::SessionStarted::V1 do |m, accumulator|
            accumulator.to_s + m.trace_id
          end
        end
      end

      let(:messages) do
        [
          build(
            :message,
            schema: Events::SessionStarted::V1,
            stream_id: user_id,
            data: Core::Nothing
          )
        ]
      end
      let(:user_id) { SecureRandom.uuid }

      it "raises a AccumulatorChangedError" do
        expect { sub_klass.new.project(messages) }.to raise_error(described_class::AccumulatorChangedError)
      end
    end

    context "when everything works" do
      let(:sub_klass) do
        Class.new(described_class) do
          projection_stream Streams::User

          def init
            0
          end

          on_message Events::SessionStarted::V1 do |_m, accumulator|
            accumulator + 1
          end
        end
      end
      let(:count) { 15 }
      let(:user_id) { SecureRandom.uuid }
      let(:messages) do
        build_list(
          :message,
          count,
          schema: Events::SessionStarted::V1,
          stream_id: user_id,
          data: Core::Nothing
        )
      end

      it "returns the projection value" do
        expect(sub_klass.new.project(messages)).to eq(count)
      end
    end
  end
end
