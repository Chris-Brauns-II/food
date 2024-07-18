require 'rails_helper'

RSpec.describe Teams::TeamsQuery do
  describe ".all_teams" do
    subject { described_class.all_teams }

    let!(:team1) { create(:teams__team, name: "1") }
    let!(:team2) { create(:teams__team, name: "2") }

    it "Returns all teams" do
      expect(subject).to contain_exactly(
        {
          id: team1.id,
          name: team1.name
        },
        {
          id: team2.id,
          name: team2.name
        }
      )
    end
  end
end
