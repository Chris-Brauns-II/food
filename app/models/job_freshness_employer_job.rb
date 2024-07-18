# == Schema Information
#
# Table name: job_freshness_employer_jobs
#
#  id               :bigint           not null, primary key
#  employer_id      :string           not null
#  recruiter_exists :boolean          default(FALSE), not null
#  jobs             :string           default([]), not null, is an Array
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class JobFreshnessEmployerJob < ApplicationRecord
end
