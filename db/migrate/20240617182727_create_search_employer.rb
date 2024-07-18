class CreateSearchEmployer < ActiveRecord::Migration[7.1]
  def change
    create_table :search_employers, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.text :logo_url
    end
  end
end
