require 'rails_helper'

RSpec.describe TrainingProviders::TrainingProviderReactor do
  it_behaves_like "a replayable message consumer"

  let(:instance) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:messages) { [] }

  describe "#handle_message" do
    subject do
      instance.handle_message(message)
      instance.handle_message(message)
    end

    before do
      messages.each do |message|
        Event.from_message!(message)
      end
    end

    context "when the message is create training provider" do
      let(:message) do
        build(
          :message,
          schema: Commands::CreateTrainingProvider::V1,
          data: {
            name: "A",
            description: "D"
          }
        )
      end

      it "emits a TrainingProviderCreated event" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            schema: Events::TrainingProviderCreated::V1,
            stream: message.stream,
            trace_id: message.trace_id,
            data: {
              name: message.data.name,
              description: message.data.description
            }
          )
          .twice
          .and_call_original

        subject
      end
    end

    context "when the message is create training provider program" do
      let(:message) do
        build(
          :message,
          schema: Commands::CreateTrainingProviderProgram::V1,
          stream:,
          data: {
            program_id: SecureRandom.uuid,
            name: "N",
            description: "D"
          }
        )
      end

      let(:stream) { Streams::TrainingProvider.new(training_provider_id: SecureRandom.uuid) }

      context "when there has been a traing provider created" do
        let(:messages) do
          [
            build(
              :message,
              schema: Events::TrainingProviderCreated::V1,
              stream:,
              data: {
                name: "A",
                description: "D"
              },
              occurred_at: message.occurred_at - 1.day
            )
          ]
        end

        it "emits a training provider program created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::TrainingProviderProgramCreated::V1,
              data: {
                program_id: message.data.program_id,
                name: message.data.name,
                description: message.data.description
              }
            )
            .twice
            .and_call_original

          subject
        end
      end

      context "when there has not been a traing provider created" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is update training provider program" do
      let(:message) do
        build(
          :message,
          schema: Commands::UpdateTrainingProviderProgram::V1,
          stream:,
          data: {
            program_id:,
            name: "N",
            description: "D"
          }
        )
      end

      let(:program_id) { SecureRandom.uuid }
      let(:stream) { Streams::TrainingProvider.new(training_provider_id: SecureRandom.uuid) }

      context "when there has been a traing provider program created" do
        let(:messages) do
          [
            build(
              :message,
              schema: Events::TrainingProviderProgramCreated::V1,
              stream:,
              data: {
                program_id:,
                name: "A",
                description: "D"
              },
              occurred_at: message.occurred_at - 1.day
            )
          ]
        end

        it "emits a training provider program created event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::TrainingProviderProgramUpdated::V1,
              data: {
                program_id: message.data.program_id,
                name: message.data.name,
                description: message.data.description
              }
            )
            .twice
            .and_call_original

          subject
        end
      end

      context "when there has not been a traing provider program created" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end
  end
end
