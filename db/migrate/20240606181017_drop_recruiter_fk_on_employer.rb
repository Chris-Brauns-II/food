class DropRecruiterFkOnEmployer < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :recruiters, :employers
  end
end
