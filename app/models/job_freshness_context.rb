# == Schema Information
#
# Table name: job_freshness_contexts
#
#  id               :uuid             not null, primary key
#  applicants       :jsonb            not null
#  employer_name    :string           not null
#  employment_title :string           not null
#  hidden           :boolean          default(FALSE), not null
#  job_id           :uuid             not null
#  recruiter_exists :boolean          default(FALSE), not null
#  status           :string           default("fresh"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class JobFreshnessContext < ApplicationRecord
end
