# == Schema Information
#
# Table name: chats_read_receipts
#
#  id                       :bigint           not null, primary key
#  read_until               :datetime         not null
#  chats_applicant_chats_id :bigint           not null
#  user_id                  :string           not null
#
# Indexes
#
#  index_chats_read_receipts_on_chats_applicant_chats_id  (chats_applicant_chats_id)
#  index_chats_read_receipts_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chats_applicant_chats_id => chats_applicant_chats.id)
#
module Chats
  class ReadReceipt < ApplicationRecord
    belongs_to :applicant_chat, class_name: "Chats::ApplicantChat", foreign_key: "chats_applicant_chats_id", inverse_of: :read_receipts
  end
end
