module Invites
  class InvitesReactor < MessageReactor
    def can_replay?
      true
    end

    MissingInviteOrUserEventError = Class.new(StandardError)
    MissingEmployerEventError = Class.new(StandardError)
    MissingTrainingProviderEventError = Class.new(StandardError)

    on_message Commands::AcceptEmployerInvite::V1 do |message|
      user_created = Projectors::Streams::GetFirst.project(
        schema: Events::UserCreated::V1,
        stream: Streams::User.new(user_id: message.data.user_id)
      )

      invite_created = Projectors::Streams::GetFirst.project(
        schema: Events::EmployerInviteCreated::V1,
        stream: message.stream
      )

      raise MissingInviteOrUserEventError if user_created.blank? || invite_created.blank?

      if user_created.data.email == invite_created.data.invite_email
        message_service.create_once_for_stream!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::EmployerInviteAccepted::V2,
          data: {
            user_id: message.data.user_id,
            invite_email: invite_created.data.invite_email,
            employer_id: invite_created.data.employer_id,
            employer_name: invite_created.data.employer_name
          }
        )
      else
        message_service.create_once_for_stream!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::EmployerInviteUsedByWrongUser::V1,
          data: {
            user_id: message.data.user_id
          }
        )
      end
    end

    on_message Commands::CreateEmployerInvite::V1 do |message|
      messages = MessageService.stream_events(Streams::Employer.new(employer_id: message.data.employer_id))
      name = Employers::Projectors::Name.new.project(messages)&.name

      raise MissingEmployerEventError if name.blank?

      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::EmployerInviteCreated::V1,
        data: {
          invite_email: message.data.invite_email,
          first_name: message.data.first_name,
          last_name: message.data.last_name,
          employer_id: message.data.employer_id,
          employer_name: name
        }
      )
    end

    on_message Commands::AcceptTrainingProviderInvite::V1 do |message|
      user_created = Projectors::Streams::GetFirst.project(
        schema: Events::UserCreated::V1,
        stream: Streams::User.new(user_id: message.data.user_id)
      )

      invite_created = Projectors::Streams::GetFirst.project(
        schema: Events::TrainingProviderInviteCreated::V1,
        stream: message.stream
      )

      raise MissingInviteOrUserEventError if user_created.blank? || invite_created.blank?

      if user_created.data.email == invite_created.data.invite_email
        message_service.create_once_for_stream!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::TrainingProviderInviteAccepted::V2,
          data: {
            training_provider_profile_id: SecureRandom.uuid,
            user_id: message.data.user_id,
            invite_email: invite_created.data.invite_email,
            training_provider_id: invite_created.data.training_provider_id,
            training_provider_name: invite_created.data.training_provider_name
          }
        )
      else
        message_service.create_once_for_stream!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::TrainingProviderInviteUsedByWrongUser::V1,
          data: {
            user_id: message.data.user_id
          }
        )
      end
    end

    on_message Commands::CreateTrainingProviderInvite::V1 do |message|
      name = Projectors::Streams::GetFirst.project(
        schema: Events::TrainingProviderCreated::V1,
        stream: Streams::TrainingProvider.new(training_provider_id: message.data.training_provider_id)
      )&.data&.name

      raise MissingTrainingProviderEventError if name.blank?

      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::TrainingProviderInviteCreated::V1,
        data: {
          invite_email: message.data.invite_email,
          first_name: message.data.first_name,
          last_name: message.data.last_name,
          training_provider_id: message.data.training_provider_id,
          role_description: message.data.role_description,
          training_provider_name: name
        }
      )
    end
  end
end
