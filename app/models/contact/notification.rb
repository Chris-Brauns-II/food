# == Schema Information
#
# Table name: contact_notifications
#
#  id         :uuid             not null, primary key
#  body       :string
#  read_at    :datetime
#  title      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :text             not null
#
# Indexese
#
#  index_contact_notifications_on_user_id  (user_id)
#
module Contact
  class Notification < ApplicationRecord
    self.table_name = "contact_notifications"

    scope :unread, -> { where(read_at: nil) }

    def read?
      read_at.present?
    end
  end
end
