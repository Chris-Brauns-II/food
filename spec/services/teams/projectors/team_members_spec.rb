require 'rails_helper'

RSpec.describe Teams::Projectors::TeamMembers do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Teams::Streams::Team.new(team_id:) }
    let(:team_id) { SecureRandom.uuid }

    let(:user_added_to_team1) do
      build(
        :message,
        stream:,
        schema: Teams::Events::UserAddedToTeam::V1,
        data: {
          user_id: "1"
        }
      )
    end
    let(:user_added_to_team2) do
      build(
        :message,
        stream:,
        schema: Teams::Events::UserAddedToTeam::V1,
        data: {
          user_id: "2"
        }
      )
    end
    let(:user_removed_from_team1) do
      build(
        :message,
        stream:,
        schema: Teams::Events::UserRemovedFromTeam::V1,
        data: {
          user_id: "1"
        }
      )
    end

    let(:messages) { [user_added_to_team1, user_removed_from_team1, user_added_to_team2] }

    it "determines the user id on the team" do
      expect(subject.team).to eq(Set.new(["2"]))
    end
  end
end
