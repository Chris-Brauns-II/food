module Infrastructure
  module TaskStates
    ALL = [
      ENQUEUED = "enqueued".freeze,
      CANCELLED = "cancelled".freeze,
      EXECUTED = "executed".freeze
    ].freeze
  end
end
