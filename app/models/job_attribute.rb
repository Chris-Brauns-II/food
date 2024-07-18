# == Schema Information
#
# Table name: job_attributes
#
#  id             :uuid             not null, primary key
#  acceptible_set :string           default([]), not null, is an Array
#  attribute_name :string           not null
#  attribute_id   :uuid             not null
#  job_id         :text             not null
#
# Indexes
#
#  index_job_attributes_on_job_id  (job_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_id => jobs.id)
#
class JobAttribute < ApplicationRecord
  belongs_to :job
end
