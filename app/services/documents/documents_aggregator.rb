module Documents
  class DocumentsAggregator < MessageConsumer
    def reset_for_replay
      Resume.delete_all
      Screener.delete_all
    end

    on_message Events::ResumeGenerationRequested::V1 do |message|
      Resume.create!(
        id: message.stream.id,
        person_id: message.data.person_id,
        anonymized: message.data.anonymized,
        document_kind: message.data.document_kind,
        requestor_id: message.metadata.requestor_id,
        requestor_type: message.metadata.requestor_type,
        status: DocumentStatus::PROCESSING
      )
    end

    on_message Events::ResumeGenerated::V1 do |message|
      Resume.update!(
        message.stream.id,
        storage_identifier: message.data.storage_identifier,
        storage_kind: message.data.storage_kind,
        document_generated_at: message.occurred_at,
        status: DocumentStatus::SUCCEEDED
      )
    end

    on_message Events::ResumeGenerationFailed::V1 do |message|
      Resume.update!(
        message.stream.id,
        status: DocumentStatus::FAILED
      )
    end

    on_message Events::ScreenerGenerationRequested::V1 do |message|
      Screener.create!(
        id: message.stream.id,
        screener_answers_id: message.data.screener_answers_id,
        document_kind: message.data.document_kind,
        requestor_id: message.metadata.requestor_id,
        requestor_type: message.metadata.requestor_type,
        status: DocumentStatus::PROCESSING
      )
    end

    on_message Events::ScreenerGenerated::V1 do |message|
      Screener.update!(
        message.stream.id,
        storage_identifier: message.data.storage_identifier,
        storage_kind: message.data.storage_kind,
        document_generated_at: message.occurred_at,
        person_id: message.data.person_id,
        status: DocumentStatus::SUCCEEDED
      )
    end

    on_message Events::ScreenerGenerationFailed::V1 do |message|
      Screener.update!(
        message.stream.id,
        status: DocumentStatus::FAILED
      )
    end
  end
end
