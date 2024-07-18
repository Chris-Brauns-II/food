require 'rails_helper'

RSpec.describe TrainingProviders::TrainingProviderAggregator do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "person training provider created" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonTrainingProviderAdded::V1,
          stream_id: SecureRandom.uuid,
          data: {
            id: SecureRandom.uuid,
            status: "doing good!",
            program_id: program.id,
            training_provider_id: training_provider.id
          }
        )
      end

      let(:program) { create(:program, training_provider:) }
      let(:training_provider) { create(:training_provider) }

      it "creates a seeker training provider" do
        expect { subject }.to change(SeekerTrainingProvider, :count).from(0).to(1)

        seeker_training_provider = SeekerTrainingProvider.take(1).first
        expect(seeker_training_provider.id).to eq(message.data.id)
        expect(seeker_training_provider.seeker_id).to eq(message.stream.id)
        expect(seeker_training_provider.program_id).to eq(message.data.program_id)
        expect(seeker_training_provider.training_provider_id).to eq(message.data.training_provider_id)
        expect(seeker_training_provider.status).to eq(message.data.status)
      end
    end

    context "training provider created" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderCreated::V1,
          stream_id: SecureRandom.uuid,
          data: {
            name: "T",
            description: "D"
          }
        )
      end

      it "creates a training provider" do
        expect { subject }.to change(TrainingProvider, :count).from(0).to(1)

        training_provider = TrainingProvider.first
        expect(training_provider.id).to eq(message.stream.id)
        expect(training_provider.name).to eq(message.data.name)
        expect(training_provider.description).to eq(message.data.description)
      end
    end

    context "training provider program created" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderProgramCreated::V1,
          stream_id: training_provider.id,
          data: {
            program_id: SecureRandom.uuid,
            name: "T",
            description: "D"
          }
        )
      end

      let!(:training_provider) { create(:training_provider) }

      it "creates a training provider program" do
        expect { subject }.to change(Program, :count).from(0).to(1)

        program = Program.first
        expect(program.id).to eq(message.data.program_id)
        expect(program.training_provider).to eq(training_provider)
        expect(program.name).to eq(message.data.name)
        expect(program.description).to eq(message.data.description)
      end
    end

    context "training provider program updated" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderProgramUpdated::V1,
          stream_id: training_provider.id,
          data: {
            program_id: program.id,
            name: "T",
            description: "D"
          }
        )
      end

      let!(:training_provider) { program.training_provider }
      let!(:program) { create(:program) }

      it "updates a training provider program" do
        subject

        program.reload
        expect(program.training_provider).to eq(training_provider)
        expect(program.name).to eq(message.data.name)
        expect(program.description).to eq(message.data.description)
      end
    end

    context "reference created" do
      let(:message) do
        build(
          :message,
          schema: Events::ReferenceCreated::V2,
          stream_id: reference_id,
          data: {
            reference_text: 'This is a reference',
            author_training_provider_profile_id:,
            training_provider_id:,
            seeker_id:
          }
        )
      end
      let(:reference_id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }
      let(:training_provider_id) { create(:training_provider).id }
      let(:author_training_provider_profile_id) { create(:training_provider_profile).id }

      it "creates a reference" do
        expect { subject }.to change(Reference, :count).from(0).to(1)

        reference = Reference.first
        expect(reference.reference_text).to eq(message.data.reference_text)
        expect(reference.author_profile_id).to eq(message.data.author_training_provider_profile_id)
        expect(reference.training_provider_id).to eq(message.data.training_provider_id)
        expect(reference.seeker_id).to eq(message.data.seeker_id)
      end
    end

    context "reference updated" do
      let(:message) do
        build(
          :message,
          schema: Events::ReferenceUpdated::V1,
          stream_id: reference_id,
          data: {
            reference_text: 'This is another reference'
          }
        )
      end
      let(:reference_id) { create(:reference).id }

      it "updates the reference" do
        expect { subject }.to change { Reference.find(reference_id).reference_text }.to('This is another reference')
      end
    end
  end
end
