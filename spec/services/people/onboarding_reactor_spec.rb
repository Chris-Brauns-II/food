require 'rails_helper'

RSpec.describe People::OnboardingReactor do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:trace_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }
  let(:person_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
      consumer.handle_message(message)
    end

    context "when the message is person associated to user" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAssociatedToUser::V1,
          stream_id: person_id,
          data: {
            user_id:
          }
        )
      end

      it "creates a start onboarding command" do
        expect(message_service)
          .to receive(:create_once_for_trace!)
          .with(
            schema: Commands::StartOnboarding::V2,
            trace_id: message.trace_id,
            stream: message.stream,
            data: Core::Nothing
          )
          .twice
          .and_call_original

        subject
      end
    end

    context "when the message is start onboarding" do
      let(:message) do
        build(
          :message,
          schema: Commands::StartOnboarding::V2,
          stream_id: person_id,
          data: Core::Nothing
        )
      end

      it "creates an onboarding complete event once for the stream" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            schema: Events::OnboardingStarted::V2,
            trace_id: message.trace_id,
            stream: message.stream,
            data: Core::Nothing
          )
          .twice
          .and_call_original

        subject
      end
    end

    context "when the message is complete onboarding" do
      let(:message) do
        build(
          :message,
          schema: Commands::CompleteOnboarding::V2,
          stream_id: person_id
        )
      end

      it "creates an onboarding complete event once for the stream" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            schema: Events::OnboardingCompleted::V3,
            trace_id: message.trace_id,
            stream: message.stream,
            data: Core::Nothing
          )
          .twice
          .and_call_original

        subject
      end
    end

    context "when message could trigger an onboarding complete" do
      let(:message) do
        build(
          :message,
          schema: Events::ReliabilityAdded::V2,
          data: {
            reliabilities: [Reliability::JOB]
          }
        )
      end

      let(:messages) { [] }

      before do
        allow(MessageService)
          .to receive(:stream_events)
          .with(message.stream)
          .and_return(messages)

        allow_any_instance_of(People::Projectors::OnboardingStatus)
          .to receive(:project)
          .with(messages)
          .and_return(projection)
      end

      context "when onboarding status next step is not complete" do
        let(:projection) do
          People::Projectors::OnboardingStatus.new.init
        end

        it "does nothing" do
          expect(message_service)
            .not_to receive(:create!)

          subject
        end
      end

      context "when onboarding status next step is complete_loading" do
        let(:projection) do
          People::Projectors::OnboardingStatus::Projection.new(
            start: People::Projectors::OnboardingStatus::Step.new(needed: true, provided: true),
            reliability: People::Projectors::OnboardingStatus::Step.new(needed: true, provided: true),
            employment: People::Projectors::OnboardingStatus::Step.new(needed: false, provided: true),
            education: People::Projectors::OnboardingStatus::Step.new(needed: false, provided: true),
            training: People::Projectors::OnboardingStatus::Step.new(needed: false, provided: true),
            opportunities: People::Projectors::OnboardingStatus::Step.new(needed: true, provided: true),
            complete: People::Projectors::OnboardingStatus::Step.new(needed: true, provided: false)
          )
        end

        it "emits an onboarding complete event" do
          expect(message_service)
            .to receive(:create_once_for_stream!)
            .with(
              schema: Commands::CompleteOnboarding::V2,
              stream: message.stream,
              trace_id: message.trace_id,
              data: Core::Nothing
            )
            .twice
            .and_call_original

          subject
        end
      end
    end
  end
end
