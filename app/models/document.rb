# == Schema Information
#
# Table name: documents
#
#  id         :text             not null, primary key
#  file_data  :binary           not null
#  file_name  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Document < ApplicationRecord
end
