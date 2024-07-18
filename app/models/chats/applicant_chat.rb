# == Schema Information
#
# Table name: chats_applicant_chats
#
#  id              :bigint           not null, primary key
#  chat_created_at :datetime         not null
#  chat_updated_at :datetime         not null
#  title           :string           not null
#  application_id  :uuid             not null
#  employer_id     :uuid             not null
#  seeker_id       :uuid             not null
#
# Indexes
#
#  index_chats_applicant_chats_on_application_id  (application_id)
#  index_chats_applicant_chats_on_employer_id     (employer_id)
#  index_chats_applicant_chats_on_seeker_id       (seeker_id)
#
module Chats
  class ApplicantChat < ApplicationRecord
    has_many :messages, class_name: "Chats::Message", inverse_of: :applicant_chat, dependent: :delete_all
    has_many :read_receipts, class_name: "Chats::ReadReceipt", inverse_of: :applicant_chat, dependent: :delete_all
  end
end
