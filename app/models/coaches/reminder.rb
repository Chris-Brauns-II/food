# == Schema Information
#
# Table name: coaches_reminders
#
#  id                 :uuid             not null, primary key
#  note               :text             not null
#  reminder_at        :datetime         not null
#  state              :string           not null
#  coaches_coaches_id :uuid             not null
#  message_task_id    :uuid             not null
#  person_id          :uuid
#
# Indexes
#
#  index_coaches_reminders_on_coaches_coaches_id  (coaches_coaches_id)
#
module Coaches
  class Reminder < ApplicationRecord
    belongs_to :coach, class_name: "Coaches::Coach", foreign_key: "coaches_coaches_id", inverse_of: :reminders

    validates :state, inclusion: { in: ReminderState::ALL }
  end
end
