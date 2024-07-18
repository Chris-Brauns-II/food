require 'rails_helper'

RSpec.describe Teams::TeamsAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new.handle_message(message) }

    context "when message is team added" do
      let(:message) do
        build(
          :message,
          schema: Teams::Events::Added::V1,
          data: {
            name: "Name"
          }
        )
      end

      it "creates a team" do
        expect { subject }.to change(Teams::Team, :count).from(0).to(1)

        team = Teams::Team.first
        expect(team.id).to eq(message.stream.id)
        expect(team.name).to eq(message.data.name)
      end
    end
  end
end
