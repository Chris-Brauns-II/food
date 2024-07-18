# == Schema Information
#
# Table name: infrastructure_tasks
#
#  id         :uuid             not null, primary key
#  command    :jsonb            not null
#  execute_at :datetime         not null
#  state      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_infrastructure_tasks_on_execute_at  (execute_at)
#  index_infrastructure_tasks_on_state       (state)
#
module Infrastructure
  class Task < ApplicationRecord
    self.table_name = "infrastructure_tasks"

    scope :ready_to_execute, -> { where(state: TaskStates::ENQUEUED).where(execute_at: ...Time.zone.now) }

    def execute!
      return unless state == TaskStates::ENQUEUED

      update!(state: TaskStates::EXECUTED)
    end

    def cancel!
      return unless state == TaskStates::ENQUEUED

      update!(state: TaskStates::CANCELLED)
    end

    def command=(command)
      write_attribute(:command, command.serialize)
    end

    def command
      Message.deserialize(attributes["command"].deep_symbolize_keys)
    end

    validates :state, inclusion: { in: TaskStates::ALL }
  end
end
