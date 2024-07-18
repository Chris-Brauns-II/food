require 'rails_helper'

RSpec.describe Teams::TeamsReactor do
  it_behaves_like "a replayable message consumer"

  before do
    messages.each do |message|
      Event.from_message!(message)
    end
  end

  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:trace_id) { SecureRandom.uuid }
  let(:messages) { [] }
  let(:stream) { Teams::Streams::Team.new(team_id:) }
  let(:team_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is add" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Teams::Commands::Add::V1,
          data: {
            name: "Best Team!"
          }
        )
      end

      context "when there is no colliding team name" do
        it "emit a added event" do
          expect(message_service)
            .to receive(:create_once_for_stream!)
            .with(
              stream: message.stream,
              trace_id: message.trace_id,
              schema: Teams::Events::Added::V1,
              data: {
                name: message.data.name
              }
            ).and_call_original

          subject
        end
      end

      context "when there is a colliding team name" do
        let(:messages) do
          [
            build(
              :message,
              schema: Teams::Events::Added::V1,
              data: {
                name: "Best Team!"
              }
            )
          ]
        end
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is add primary slack channel" do
      let(:message) do
        build(
          :message,
          schema: Teams::Commands::AddPrimarySlackChannel::V1,
          data: {
            channel: "#dah_place"
          }
        )
      end

      it "emits a primary slack channel added" do
        expect(message_service)
          .to receive(:create_once_for_trace!)
          .with(
            stream: message.stream,
            trace_id: message.trace_id,
            schema: Teams::Events::PrimarySlackChannelAdded::V1,
            data: {
              channel: message.data.channel
            }
          ).and_call_original

        subject
      end
    end

    context "when the message is add user to team" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Teams::Commands::AddUserToTeam::V1,
          data: {
            user_id: "1"
          }
        )
      end

      context "when the user is not on the team" do
        it "emits an user added to team event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              stream: message.stream,
              trace_id: message.trace_id,
              schema: Teams::Events::UserAddedToTeam::V1,
              data: {
                user_id: message.data.user_id
              }
            ).and_call_original

          subject
        end
      end

      context "when the user is on the team" do
        let(:messages) do
          [
            build(
              :message,
              stream:,
              schema: Teams::Events::UserAddedToTeam::V1,
              data: {
                user_id: "1"
              }
            )
          ]
        end
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is send slack message" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Teams::Commands::SendSlackMessage::V2,
          data: {
            text: "yo",
            blocks: nil
          }
        )
      end

      context "when no slack channel has been set" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when a slack channel has been set" do
        let(:messages) do
          [
            build(
              :message,
              stream:,
              schema: Teams::Events::PrimarySlackChannelAdded::V1,
              data: {
                channel: "#cool_channel"
              }
            )
          ]
        end

        it "emits a send slack message command" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              message_id: be_a(String),
              trace_id: message.trace_id,
              schema: Commands::SendSlackMessage::V2,
              data: {
                text: message.data.text,
                channel: "#cool_channel",
                blocks: nil
              }
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is remvove user to team" do
      let(:message) do
        build(
          :message,
          stream:,
          schema: Teams::Commands::RemoveUserFromTeam::V1,
          data: {
            user_id: "1"
          }
        )
      end

      context "when the user is not on the team" do
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the user is on the team" do
        let(:messages) do
          [
            build(
              :message,
              stream:,
              schema: Teams::Events::UserAddedToTeam::V1,
              data: {
                user_id: "1"
              }
            )
          ]
        end

        it "emits an user remvoed to team event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              stream: message.stream,
              trace_id: message.trace_id,
              schema: Teams::Events::UserRemovedFromTeam::V1,
              data: {
                user_id: message.data.user_id
              }
            ).and_call_original

          subject
        end
      end
    end
  end
end
