# == Schema Information
#
# Table name: analytics_dim_employers
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  employer_id :uuid             not null
#
# Indexes
#
#  index_analytics_dim_employers_on_employer_id  (employer_id) UNIQUE
#
module Analytics
  class DimEmployer < ApplicationRecord
    has_many :dim_jobs, class_name: "Analytics::DimJob", dependent: :delete_all
  end
end
