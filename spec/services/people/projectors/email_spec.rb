require 'rails_helper'

RSpec.describe People::Projectors::Email do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Person.new(person_id:) }
    let(:person_id) { SecureRandom.uuid }

    let(:person_added_with_email) do
      build(
        :message,
        stream:,
        schema: Events::PersonAdded::V1,
        data: {
          email: SecureRandom.uuid,
          phone_number: nil,
          first_name: "Some",
          last_name: "Body",
          date_of_birth: nil
        }
      )
    end
    let(:person_added_without_email) do
      build(
        :message,
        stream:,
        schema: Events::PersonAdded::V1,
        data: {
          email: nil,
          phone_number: "333-333-3333",
          first_name: "Some",
          last_name: "Body",
          date_of_birth: nil
        }
      )
    end
    let(:basic_info_added_without_email) do
      build(
        :message,
        stream:,
        schema: Events::BasicInfoAdded::V1,
        data: {
          email: nil,
          first_name: "Some",
          last_name: "Body",
          phone_number: "333-333-3333"
        }
      )
    end
    let(:basic_info_added_with_email) do
      build(
        :message,
        stream:,
        schema: Events::BasicInfoAdded::V1,
        data: {
          email: SecureRandom.uuid,
          first_name: "Some",
          last_name: "Body",
          phone_number: "333-333-3333"
        }
      )
    end

    context "when the person added has an email" do
      let(:messages) { [person_added_with_email, basic_info_added_without_email, basic_info_added_with_email] }

      it "determines the initial and current email" do
        expect(subject.initial_email).to eq(person_added_with_email.data.email)
        expect(subject.current_email).to eq(basic_info_added_with_email.data.email)
      end
    end

    context "when the person added doesn't have an email" do
      let(:messages) { [person_added_without_email, basic_info_added_without_email, basic_info_added_with_email] }

      it "determines the initial and current email" do
        expect(subject.initial_email).to eq(basic_info_added_with_email.data.email)
        expect(subject.current_email).to eq(basic_info_added_with_email.data.email)
      end
    end
  end
end
