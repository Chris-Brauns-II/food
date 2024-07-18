module Teams
  class TeamsAggregator < MessageConsumer
    def reset_for_replay
      Team.delete_all
    end

    on_message Events::Added::V1 do |message|
      Team.create!(id: message.stream.id, name: message.data.name)
    end
  end
end
