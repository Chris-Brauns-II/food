require 'rails_helper'

RSpec.describe Invites::InvitesAggregator do
  let(:consumer) { described_class.new }
  let(:id) { SecureRandom.uuid }

  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is employer invite created" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerInviteCreated::V1,
          data: {
            invite_email: "An email",
            first_name: "First",
            last_name: "Last",
            employer_id: SecureRandom.uuid,
            employer_name: "A name"
          }
        )
      end

      it "creates an employer invite" do
        expect { subject }.to change(Invites::EmployerInvite, :count).from(0).to(1)

        employer_invite = Invites::EmployerInvite.first
        expect(employer_invite.id).to eq(message.stream.id)
        expect(employer_invite.email).to eq(message.data.invite_email)
        expect(employer_invite.first_name).to eq(message.data.first_name)
        expect(employer_invite.last_name).to eq(message.data.last_name)
        expect(employer_invite.employer_id).to eq(message.data.employer_id)
        expect(employer_invite.employer_name).to eq(message.data.employer_name)
      end
    end

    context "when the message is employer invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerInviteAccepted::V2,
          stream_id: employer_invite.id,
          data: {
            user_id: SecureRandom.uuid,
            invite_email: "a email",
            employer_id: SecureRandom.uuid,
            employer_name: "Employer"
          }
        )
      end

      let(:employer_invite) { create(:invites__employer_invite) }

      it "marks the employer invite as used" do
        subject

        employer_invite.reload
        expect(employer_invite.used_at).to eq(message.occurred_at)
      end
    end

    context "when the message is training provider invite created" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderInviteCreated::V1,
          data: {
            invite_email: "An email",
            first_name: "First",
            last_name: "Last",
            training_provider_id: SecureRandom.uuid,
            training_provider_name: "Get trained",
            role_description: "A name"
          }
        )
      end

      it "creates an training provider invite" do
        expect { subject }.to change(Invites::TrainingProviderInvite, :count).from(0).to(1)

        training_provider_invite = Invites::TrainingProviderInvite.first
        expect(training_provider_invite.id).to eq(message.stream.id)
        expect(training_provider_invite.email).to eq(message.data.invite_email)
        expect(training_provider_invite.first_name).to eq(message.data.first_name)
        expect(training_provider_invite.last_name).to eq(message.data.last_name)
        expect(training_provider_invite.training_provider_id).to eq(message.data.training_provider_id)
        expect(training_provider_invite.training_provider_name).to eq(message.data.training_provider_name)
        expect(training_provider_invite.role_description).to eq(message.data.role_description)
      end
    end

    context "when the message is training provider invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderInviteAccepted::V2,
          stream_id: training_provider_invite.id,
          data: {
            training_provider_profile_id: SecureRandom.uuid,
            user_id: SecureRandom.uuid,
            invite_email: "a email",
            training_provider_id: SecureRandom.uuid,
            training_provider_name: "Employer"
          }
        )
      end

      let(:training_provider_invite) { create(:invites__training_provider_invite) }

      it "marks the training provider invite as used" do
        subject

        training_provider_invite.reload
        expect(training_provider_invite.used_at).to eq(message.occurred_at)
      end
    end
  end
end
