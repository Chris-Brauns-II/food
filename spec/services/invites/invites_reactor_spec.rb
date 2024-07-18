require 'rails_helper'

RSpec.describe Invites::InvitesReactor do
  let(:consumer) { described_class.new(message_service:) }
  let(:id) { SecureRandom.uuid }
  let(:message_service) { MessageService.new }
  let(:messages) { [] }

  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
      consumer.handle_message(message)
    end

    before do
      messages.each do |message|
        Event.from_message!(message)
      end
    end

    context "when the message is accept employer invite" do
      let(:message) do
        build(
          :message,
          schema: Commands::AcceptEmployerInvite::V1,
          stream_id: id,
          data: {
            user_id:
          }
        )
      end
      let(:user_id) { SecureRandom.uuid }
      let(:user_created_email) { "A@B.com" }
      let(:employer_invite_created_email) { "A@B.com" }

      let(:user_created) do
        build(
          :message,
          schema: Events::UserCreated::V1,
          stream_id: user_id,
          data: {
            email: user_created_email
          }
        )
      end
      let(:employer_invite_created) do
        build(
          :message,
          schema: Events::EmployerInviteCreated::V1,
          stream_id: id,
          data: {
            invite_email: employer_invite_created_email,
            first_name: "Jim",
            last_name: "Jimson",
            employer_id: SecureRandom.uuid,
            employer_name: "Employer"
          }
        )
      end

      context "when user created is missing" do
        let(:messages) { [employer_invite_created] }

        it "raises a MissingInviteOrUserEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingInviteOrUserEventError, message)
        end
      end

      context "when employer invite created is missing" do
        let(:messages) { [user_created] }

        it "raises a MissingInviteOrUserEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingInviteOrUserEventError, message)
        end
      end

      context "when the needed messages are present" do
        let(:messages) { [user_created, employer_invite_created] }

        context "when the emails don't match" do
          let(:user_created_email) { "A@B.C" }
          let(:employer_invite_created_email) { "D@E.F" }

          it "emits a EmployerInviteUsedByWrongUser" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                trace_id: message.trace_id,
                stream: message.stream,
                schema: Events::EmployerInviteUsedByWrongUser::V1,
                data: {
                  user_id: message.data.user_id
                }
              )
              .twice
              .and_call_original

            subject
          end
        end

        context "when the emails do match" do
          let(:user_created_email) { "A@B.C" }
          let(:employer_invite_created_email) { user_created_email }

          it "emits a EmployerInviteAccepted" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                trace_id: message.trace_id,
                stream: message.stream,
                schema: Events::EmployerInviteAccepted::V2,
                data: {
                  user_id: message.data.user_id,
                  invite_email: employer_invite_created.data.invite_email,
                  employer_id: employer_invite_created.data.employer_id,
                  employer_name: employer_invite_created.data.employer_name
                }
              )
              .twice
              .and_call_original

            subject
          end
        end
      end
    end

    context "when the message is create employer invite" do
      let(:message) do
        build(
          :message,
          schema: Commands::CreateEmployerInvite::V1,
          stream_id: id,
          data: {
            invite_email: "An email",
            first_name: "First",
            last_name: "Last",
            employer_id:
          }
        )
      end
      let(:employer_id) { SecureRandom.uuid }

      context "when the employer does not exist" do
        it "raises a MissingEmployerEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingEmployerEventError, message)
        end
      end

      context "when the employer does exist" do
        let(:messages) do
          [
            build(
              :message,
              schema: Events::EmployerCreated::V1,
              stream_id: employer_id,
              data: {
                name: "An email",
                location: "First",
                bio: "Last",
                logo_url: "www.google.com"
              }
            )
          ]
        end

        it "emits an employer invite created event" do
          expect(message_service)
            .to receive(:create_once_for_stream!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::EmployerInviteCreated::V1,
              data: {
                invite_email: message.data.invite_email,
                first_name: message.data.first_name,
                last_name: message.data.last_name,
                employer_id: message.data.employer_id,
                employer_name: "An email"
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end

    context "when the message is accept training provider invite" do
      let(:message) do
        build(
          :message,
          schema: Commands::AcceptTrainingProviderInvite::V1,
          stream_id: id,
          data: {
            user_id:
          }
        )
      end
      let(:user_id) { SecureRandom.uuid }
      let(:user_created_email) { "A@B.com" }
      let(:training_provider_invite_created_email) { "A@B.com" }

      let(:user_created) do
        build(
          :message,
          schema: Events::UserCreated::V1,
          stream_id: user_id,
          data: {
            email: user_created_email
          }
        )
      end
      let(:training_provider_invite_created) do
        build(
          :message,
          schema: Events::TrainingProviderInviteCreated::V1,
          stream_id: id,
          data: {
            invite_email: training_provider_invite_created_email,
            first_name: "Jim",
            last_name: "Jimson",
            role_description: "A role",
            training_provider_id: SecureRandom.uuid,
            training_provider_name: "Training"
          }
        )
      end

      context "when user created is missing" do
        let(:messages) { [training_provider_invite_created] }

        it "raises a MissingInviteOrUserEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingInviteOrUserEventError, message)
        end
      end

      context "when employer invite created is missing" do
        let(:messages) { [user_created] }

        it "raises a MissingInviteOrUserEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingInviteOrUserEventError, message)
        end
      end

      context "when the needed messages are present" do
        let(:messages) { [user_created, training_provider_invite_created] }

        context "when the emails don't match" do
          let(:user_created_email) { "A@B.C" }
          let(:training_provider_invite_created_email) { "D@E.F" }

          it "emits a TrainingProviderInviteUsedByWrongUser" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                trace_id: message.trace_id,
                stream: message.stream,
                schema: Events::TrainingProviderInviteUsedByWrongUser::V1,
                data: {
                  user_id: message.data.user_id
                }
              )
              .twice
              .and_call_original

            subject
          end
        end

        context "when the emails do match" do
          let(:user_created_email) { "A@B.C" }
          let(:training_provider_invite_created_email) { user_created_email }

          it "emits a TrainingProviderInviteAccepted" do
            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                trace_id: message.trace_id,
                stream: message.stream,
                schema: Events::TrainingProviderInviteAccepted::V2,
                data: {
                  training_provider_profile_id: be_a(String),
                  user_id: message.data.user_id,
                  invite_email: training_provider_invite_created.data.invite_email,
                  training_provider_id: training_provider_invite_created.data.training_provider_id,
                  training_provider_name: training_provider_invite_created.data.training_provider_name
                }
              )
              .twice
              .and_call_original

            subject
          end
        end
      end
    end

    context "when the message is create training provider invite" do
      let(:message) do
        build(
          :message,
          schema: Commands::CreateTrainingProviderInvite::V1,
          stream_id: id,
          data: {
            invite_email: "An email",
            first_name: "First",
            last_name: "Last",
            role_description: "Role",
            training_provider_id:
          }
        )
      end
      let(:training_provider_id) { SecureRandom.uuid }

      context "when the training provider does not exist" do
        it "raises a MissingTrainingProviderEventError" do
          expect { subject }.to raise_consumer_error(described_class::MissingTrainingProviderEventError, message)
        end
      end

      context "when the employer does exist" do
        let(:messages) do
          [
            build(
              :message,
              schema: Events::TrainingProviderCreated::V1,
              stream_id: training_provider_id,
              data: {
                name: "Cat",
                description: "Meow"
              }
            )
          ]
        end

        it "emits an employer invite created event" do
          expect(message_service)
            .to receive(:create_once_for_stream!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Events::TrainingProviderInviteCreated::V1,
              data: {
                invite_email: message.data.invite_email,
                first_name: message.data.first_name,
                last_name: message.data.last_name,
                training_provider_id: message.data.training_provider_id,
                role_description: message.data.role_description,
                training_provider_name: "Cat"
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end
  end
end
