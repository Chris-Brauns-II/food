class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.last_created
    order(created_at: :desc).first
  end
end
