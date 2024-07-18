# == Schema Information
#
# Table name: invites_employer_invites
#
#  id            :uuid             not null, primary key
#  email         :string           not null
#  employer_name :string           not null
#  first_name    :string           not null
#  last_name     :string           not null
#  used_at       :datetime
#  employer_id   :uuid             not null
#
module Invites
  class EmployerInvite < ApplicationRecord
  end
end
