module Teams
  class TeamsQuery
    def self.all_teams
      Team.all.map do |team|
        serialize_team(team)
      end
    end

    class << self
      private

      def serialize_team(team)
        {
          id: team.id,
          name: team.name
        }
      end
    end
  end
end
