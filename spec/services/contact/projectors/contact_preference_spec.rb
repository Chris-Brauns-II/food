require 'rails_helper'

RSpec.describe Contact::Projectors::ContactPreference do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Person.new(person_id:) }
    let(:person_id) { SecureRandom.uuid }

    let(:person_added) do
      build(
        :message,
        stream:,
        schema: Events::PersonAdded::V1,
        data: {
          email: "a@b.c",
          phone_number: nil,
          first_name: "Some",
          last_name: "Body",
          date_of_birth: nil
        }
      )
    end
    let(:basic_info_added) do
      build(
        :message,
        stream:,
        schema: Events::BasicInfoAdded::V1,
        data: {
          email: "d@e.f",
          first_name: "Some",
          last_name: "Body",
          phone_number: "333-333-3333"
        }
      )
    end
    let(:slack_id_added) do
      build(
        :message,
        stream:,
        schema: Events::SlackIdAdded::V2,
        data: {
          slack_id: 'slack'
        }
      )
    end
    let(:person_associated_to_user) do
      build(
        :message,
        stream:,
        schema: Events::PersonAssociatedToUser::V1,
        data: {
          user_id: "user1"
        }
      )
    end
    let(:contact_preference_set) do
      build(
        :message,
        stream:,
        schema: Events::ContactPreferenceSet::V2,
        data: {
          preference: Contact::ContactPreference::EMAIL
        }
      )
    end

    context "when no messages are passed" do
      let(:messages) { [] }

      it "sets nothing and calling prefence raises" do
        expect(subject.phone_number).to eq(nil)
        expect(subject.email).to eq(nil)
        expect(subject.slack_id).to eq(nil)
        expect(subject.notification_user_id).to eq(nil)

        expect { subject.preference }.to raise_error(described_class::Projection::NoValidOption)
      end
    end

    context "when messages are present" do
      context "when a preference is not set" do
        let(:messages) do
          [
            person_added,
            basic_info_added,
            slack_id_added,
            person_associated_to_user
          ]
        end

        it "picks the highest precedent contact method" do
          expect(subject.phone_number).to eq("333-333-3333")
          expect(subject.email).to eq("d@e.f")
          expect(subject.slack_id).to eq("slack")
          expect(subject.notification_user_id).to eq("user1")

          expect(subject.preference).to eq(Contact::ContactPreference::SLACK)
        end
      end

      context "when a preference is set" do
        let(:messages) do
          [
            person_added,
            contact_preference_set,
            slack_id_added,
            person_associated_to_user,
            basic_info_added
          ]
        end

        it "picks the highest precedent contact method" do
          expect(subject.phone_number).to eq("333-333-3333")
          expect(subject.email).to eq("d@e.f")
          expect(subject.slack_id).to eq("slack")
          expect(subject.notification_user_id).to eq("user1")

          expect(subject.preference).to eq(Contact::ContactPreference::EMAIL)
        end
      end
    end
  end
end
