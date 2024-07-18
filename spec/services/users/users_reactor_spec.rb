require 'rails_helper'

RSpec.describe Users::UsersReactor do
  describe "#handle_message" do
    subject { instance.handle_message(message) }

    let(:message_service) { MessageService.new }
    let(:instance) { described_class.new(message_service:) }

    context "when message is role added" do
      let(:message) do
        build(
          :message,
          schema: Events::RoleAdded::V2,
          stream_id: user_id,
          data: {
            role:
          }
        )
      end

      let(:user_id) { SecureRandom.uuid }

      context "when role is not coach" do
        let(:role) { Role::Types::ADMIN }

        it "does nothing" do
          expect(message_service)
            .not_to receive(:create!)

          subject
        end
      end

      context "when role is coach" do
        before do
          allow(MessageService)
            .to receive(:stream_events)
            .with(stream)
            .and_return(messages)
        end

        let(:user_created) do
          build(
            :message,
            schema: Events::UserCreated::V1,
            stream_id: user_id,
            data: {
              email:
            }
          )
        end

        let(:email) { nil }
        let(:role) { Role::Types::COACH }
        let(:stream) { Streams::User.new(user_id:) }

        context "when a user created does not exist" do
          let(:messages) { [] }

          it "does nothing" do
            expect(message_service)
              .not_to receive(:create!)

            subject
          end
        end

        context "when a user created does not have an email" do
          let(:messages) { [user_created] }
          let(:email) { nil }

          it "does nothing" do
            expect(message_service)
              .not_to receive(:create!)

            subject
          end
        end

        context "when a user created does not have an email" do
          let(:messages) { [user_created] }
          let(:email) { "some@email.com" }

          it "emits a coach added event once" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                trace_id: message.trace_id,
                schema: Events::CoachAdded::V1,
                user_id: message.stream.id,
                data: {
                  coach_id: be_a(String),
                  email:
                }
              )
              .and_call_original

            subject
          end
        end
      end
    end
  end
end
