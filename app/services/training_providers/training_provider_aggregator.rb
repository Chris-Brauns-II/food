module TrainingProviders
  class TrainingProviderAggregator < MessageConsumer
    def reset_for_replay
      Reference.delete_all
      SeekerTrainingProvider.delete_all
      Program.delete_all
      TrainingProvider.delete_all
    end

    on_message Events::PersonTrainingProviderAdded::V1 do |message|
      seeker_training_provider_created = SeekerTrainingProvider.find_or_initialize_by(id: message.data.id)

      seeker_training_provider_created.update!(
        program_id: message.data.program_id,
        status: message.data.status,
        seeker_id: message.stream.id,
        training_provider_id: message.data.training_provider_id
      )
    end

    on_message Events::TrainingProviderCreated::V1 do |message|
      TrainingProvider.create!(
        id: message.stream.id,
        name: message.data.name,
        description: message.data.description
      )
    end

    on_message Events::TrainingProviderProgramCreated::V1 do |message|
      Program.create!(
        id: message.data.program_id,
        training_provider_id: message.stream.id,
        name: message.data.name,
        description: message.data.description
      )
    end

    on_message Events::TrainingProviderProgramUpdated::V1 do |message|
      Program.update!(
        message.data.program_id,
        training_provider_id: message.stream.id,
        name: message.data.name,
        description: message.data.description
      )
    end

    on_message Events::ReferenceCreated::V2 do |message|
      Reference.create!(
        id: message.stream.id,
        reference_text: message.data.reference_text,
        author_profile_id: message.data.author_training_provider_profile_id,
        training_provider_id: message.data.training_provider_id,
        seeker_id: message.data.seeker_id
      )
    end

    on_message Events::ReferenceUpdated::V1 do |message|
      reference = Reference.find(message.stream.id)
      reference.update!(reference_text: message.data.reference_text)
    end
  end
end
