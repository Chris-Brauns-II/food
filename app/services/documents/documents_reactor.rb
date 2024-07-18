module Documents
  class DocumentsReactor < MessageReactor
    def initialize(document_storage: Storage::Gateway.build, storage_kind: ENV.fetch("DOCUMENT_STORAGE_KIND", nil), **params)
      super(**params)
      @document_storage = document_storage
      @storage_kind = storage_kind
    end

    def can_replay?
      true
    end

    on_message Commands::GenerateResumeForPerson::V2 do |message|
      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ResumeGenerationRequested::V1,
        data: {
          person_id: message.data.person_id,
          anonymized: message.data.anonymized,
          document_kind: message.data.document_kind
        },
        metadata: message.metadata
      )

      messages = MessageService.stream_events(::Streams::Person.new(person_id: message.data.person_id))

      if messages.empty?
        message_service.create_once_for_trace!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::ResumeGenerationFailed::V1,
          data: {
            person_id: message.data.person_id,
            anonymized: message.data.anonymized,
            document_kind: message.data.document_kind,
            reason: "Person does not exist"
          },
          metadata: message.metadata
        )

        return
      end

      basic_info_projection = People::Projectors::BasicInfo.new.project(messages)
      bio = Projectors::Streams::GetLast.new(schema: ::Events::PersonAboutAdded::V1).project(messages)&.data&.about
      work_projection = People::Projectors::WorkExperiences.new.project(messages)
      education_projection = People::Projectors::EducationExperiences.new.project(messages)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Commands::GenerateResume::V3,
        data: {
          person_id: message.data.person_id,
          anonymized: message.data.anonymized,
          checks: message.data.checks,
          document_kind: message.data.document_kind,
          page_limit: message.data.page_limit,
          first_name: basic_info_projection.first_name,
          last_name: basic_info_projection.last_name,
          email: basic_info_projection.email,
          phone_number: basic_info_projection.phone_number,
          bio:,
          work_experiences: work_projection.work_experiences.values.map do |work_experience|
            Commands::GenerateResume::WorkExperience::V1.new(
              organization_name: work_experience.organization_name,
              position: work_experience.position,
              start_date: work_experience.start_date,
              end_date: work_experience.end_date,
              is_current: work_experience.is_current,
              description: work_experience.description
            )
          end,
          education_experiences: education_projection.education_experiences.values.map do |education_experience|
            Commands::GenerateResume::EducationExperience::V1.new(
              organization_name: education_experience.organization_name,
              title: education_experience.title,
              activities: education_experience.activities,
              graduation_date: education_experience.graduation_date,
              gpa: education_experience.gpa
            )
          end
        },
        metadata: message.metadata
      )
    end

    on_message Commands::GenerateResume::V3 do |message|
      pdf = ResumeGenerationService.generate_from_command(message:)

      result = document_storage.store_document(
        id: message.stream.id,
        storage_kind:,
        file_data: pdf,
        file_name: "#{message.data.first_name}-#{message.data.last_name}-resume-#{message.occurred_at.strftime('%Y-%m-%d-%H:%M')}.pdf"
      )

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ResumeGenerated::V1,
        data: {
          person_id: message.data.person_id,
          anonymized: message.data.anonymized,
          document_kind: message.data.document_kind,
          storage_kind: result.storage_kind,
          storage_identifier: result.storage_identifier
        },
        metadata: message.metadata
      )
    rescue StandardError => e
      Sentry.capture_exception(e)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ResumeGenerationFailed::V1,
        data: {
          person_id: message.data.person_id,
          anonymized: message.data.anonymized,
          document_kind: message.data.document_kind,
          reason: e.message
        },
        metadata: message.metadata
      )
    end

    on_message Commands::GenerateScreenerForAnswers::V1 do |message|
      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ScreenerGenerationRequested::V1,
        data: {
          screener_answers_id: message.data.screener_answers_id,
          document_kind: message.data.document_kind
        },
        metadata: message.metadata
      )

      messages = MessageService.stream_events(::Screeners::Streams::Answers.new(screener_answers_id: message.data.screener_answers_id))

      if messages.empty?
        message_service.create_once_for_trace!(
          trace_id: message.trace_id,
          stream: message.stream,
          schema: Events::ScreenerGenerationFailed::V1,
          data: {
            person_id: nil,
            screener_answers_id: message.data.screener_answers_id,
            document_kind: message.data.document_kind,
            reason: "Screener Answers do not exist"
          },
          metadata: message.metadata
        )

        return
      end

      answers = Screeners::Projectors::ScreenerAnswers.new.project(messages)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Commands::GenerateScreener::V1,
        data: {
          screener_answers_id: message.data.screener_answers_id,
          title: answers.title,
          person_id: answers.person_id,
          question_responses: answers.question_responses,
          document_kind: message.data.document_kind
        },
        metadata: message.metadata
      )
    end

    on_message Commands::GenerateScreener::V1 do |message|
      pdf = ScreenerGenerationService.generate_from_command(message:)

      result = document_storage.store_document(
        id: message.stream.id,
        storage_kind:,
        file_data: pdf,
        file_name: "screener-#{message.data.screener_answers_id}-#{message.occurred_at.strftime('%Y-%m-%d-%H:%M')}.pdf"
      )

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ScreenerGenerated::V1,
        data: {
          person_id: message.data.person_id,
          screener_answers_id: message.data.screener_answers_id,
          document_kind: message.data.document_kind,
          storage_kind: result.storage_kind,
          storage_identifier: result.storage_identifier
        },
        metadata: message.metadata
      )
    rescue StandardError => e
      Sentry.capture_exception(e)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::ScreenerGenerationFailed::V1,
        data: {
          person_id: message.data.person_id,
          screener_answers_id: message.data.screener_answers_id,
          document_kind: message.data.document_kind,
          reason: e.message
        },
        metadata: message.metadata
      )
    end

    private

    attr_reader :document_storage, :storage_kind
  end
end
