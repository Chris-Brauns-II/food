module Contact
  module ContactPreference
    ALL = [
      SLACK = "slack".freeze,
      EMAIL = "email".freeze,
      SMS = "sms".freeze,
      IN_APP_NOTIFICATION = "in_app_notification".freeze,
      NONE = "none".freeze
    ].freeze
  end

  module MessageStates
    ALL = [
      ENQUEUED = "enqueued".freeze,
      COMPLETED = "completed".freeze,
      FAILED = "failed".freeze
    ].freeze
  end
end
