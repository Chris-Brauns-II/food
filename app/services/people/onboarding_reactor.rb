module People
  class OnboardingReactor < MessageReactor
    def can_replay?
      true
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      message_service.create_once_for_trace!(
        schema: Commands::StartOnboarding::V2,
        trace_id: message.trace_id,
        stream: message.stream,
        data: Core::Nothing
      )
    end

    on_message Commands::StartOnboarding::V2 do |message|
      message_service.create_once_for_stream!(
        schema: Events::OnboardingStarted::V2,
        trace_id: message.trace_id,
        stream: message.stream,
        data: Core::Nothing
      )
    end

    on_message Commands::CompleteOnboarding::V2, :sync do |message|
      message_service.create_once_for_stream!(
        schema: Events::OnboardingCompleted::V3,
        trace_id: message.trace_id,
        stream: message.stream,
        data: Core::Nothing
      )
    end

    on_message Events::OnboardingStarted::V2 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::BasicInfoAdded::V1 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::ReliabilityAdded::V2 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::ExperienceAdded::V2 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::EducationExperienceAdded::V2 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::PersonTrainingProviderAdded::V1 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    on_message Events::ProfessionalInterestsAdded::V2 do |message|
      emit_complete_onboarding_if_applicable(message)
    end

    private

    def emit_complete_onboarding_if_applicable(message)
      messages = MessageService.stream_events(message.stream)

      return if ::Projectors::Streams::HasOccurred.new(schema: Events::OnboardingCompleted::V3).project(messages)

      status = Projectors::OnboardingStatus.new.project(messages)
      return unless status.next_step == Onboarding::Steps::COMPLETE_LOADING

      message_service.create_once_for_stream!(
        schema: Commands::CompleteOnboarding::V2,
        stream: message.stream,
        trace_id: message.trace_id,
        data: Core::Nothing
      )
    end
  end
end
