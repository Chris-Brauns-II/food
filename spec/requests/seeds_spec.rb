require 'rails_helper'

RSpec.describe 'Seed data' do
  it 'correctly seeds the database' do
    expect { Rails.application.load_seed }.not_to raise_error
  end
end
