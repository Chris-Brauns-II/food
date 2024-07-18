# == Schema Information
#
# Table name: chats_messages
#
#  id                       :bigint           not null, primary key
#  from                     :string           not null
#  message                  :string           not null
#  message_sent_at          :datetime         not null
#  chats_applicant_chats_id :bigint           not null
#  user_id                  :string
#
# Indexes
#
#  index_chats_messages_on_chats_applicant_chats_id  (chats_applicant_chats_id)
#
# Foreign Keys
#
#  fk_rails_...  (chats_applicant_chats_id => chats_applicant_chats.id)
#
module Chats
  class Message < ApplicationRecord
    belongs_to :applicant_chat, class_name: "Chats::ApplicantChat", foreign_key: "chats_applicant_chats_id", inverse_of: :messages
  end
end
