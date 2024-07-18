# == Schema Information
#
# Table name: people_search_coaches
#
#  id    :uuid             not null, primary key
#  email :string           not null
#
module PeopleSearch
  class Coach < ApplicationRecord
  end
end
