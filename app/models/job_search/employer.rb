# == Schema Information
#
# Table name: search_employers
#
#  id       :uuid             not null, primary key
#  logo_url :text
#
module JobSearch
  class Employer < ApplicationRecord
    self.table_name = "search_employers"
  end
end
