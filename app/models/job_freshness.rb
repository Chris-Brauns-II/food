# == Schema Information
#
# Table name: job_freshnesses
#
#  id               :uuid             not null, primary key
#  job_id           :uuid
#  status           :string
#  employment_title :string
#  employer_name    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  occurred_at      :datetime         not null
#
class JobFreshness < ApplicationRecord
end
