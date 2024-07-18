require 'rails_helper'

RSpec.describe Users::UsersAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new.handle_message(message) }

    context "when message is role added" do
      let(:message) do
        build(
          :message,
          schema: Events::RoleAdded::V2,
          stream_id: user.id,
          data: {
            role:
          }
        )
      end

      let(:user) { create(:user) }
      let(:role) { Role::Types::ADMIN }

      context "when the user role doesn't exist" do
        it "creates a user role" do
          expect { subject }.to change(UserRole, :count).from(0).to(1)

          user_role = UserRole.take(1).first
          expect(user_role.user).to eq(user)
          expect(user_role.role).to eq(role)
        end
      end

      context "when the user role does exist" do
        let!(:user_role) { create(:user_role, user:, role:) }

        it "creates a user role" do
          expect { subject }.not_to change(UserRole, :count)
        end
      end
    end

    context "when message is person associated to user" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAssociatedToUser::V1,
          stream_id: id,
          data: {
            user_id: user.id
          }
        )
      end

      let(:user) { create(:user) }
      let(:id) { SecureRandom.uuid }

      it "stamps the user with person_id" do
        subject

        user.reload
        expect(user.person_id).to eq(id)
      end
    end

    context "when the message is training provider invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::TrainingProviderInviteAccepted::V2,
          data: {
            training_provider_profile_id: SecureRandom.uuid,
            user_id: user.id,
            invite_email: user.email,
            training_provider_id: SecureRandom.uuid,
            training_provider_name: "Columbus Ultra Lame"
          }
        )
      end

      let(:user) { create(:user) }

      it "creates a training provider profile" do
        expect { subject }.to change(TrainingProviderProfile, :count).from(0).to(1)

        recruiter = TrainingProviderProfile.first
        expect(recruiter.user_id).to eq(user.id)
        expect(recruiter.training_provider_id).to eq(message.data.training_provider_id)
      end
    end

    context "when the message is employer invite accepted" do
      let(:message) do
        build(
          :message,
          schema: Events::EmployerInviteAccepted::V2,
          data: {
            user_id: user.id,
            invite_email: user.email,
            employer_id: SecureRandom.uuid,
            employer_name: "A name"
          }
        )
      end

      let(:user) { create(:user) }

      it "creates a recruiter" do
        expect { subject }.to change(Recruiter, :count).from(0).to(1)

        recruiter = Recruiter.first
        expect(recruiter.user_id).to eq(user.id)
        expect(recruiter.employer_id).to eq(message.data.employer_id)
      end
    end
  end
end
