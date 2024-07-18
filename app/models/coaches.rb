module Coaches
  def self.table_name_prefix
    "coaches_"
  end

  module ReminderState
    ALL = [
      SET = "set".freeze,
      COMPLETE = "complete".freeze
    ].freeze
  end
end
