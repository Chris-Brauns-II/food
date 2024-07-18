require 'rails_helper'

RSpec.describe People::Projectors::BasicInfo do
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
          email: "A@B.com",
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
          email: nil,
          first_name: "So",
          last_name: "Bod",
          phone_number: "333-333-3333"
        }
      )
    end

    let(:messages) { [person_added, basic_info_added] }

    it "determines the first and last name" do
      expect(subject.first_name).to eq(basic_info_added.data.first_name)
      expect(subject.last_name).to eq(basic_info_added.data.last_name)
      expect(subject.email).to eq(basic_info_added.data.email)
      expect(subject.phone_number).to eq(basic_info_added.data.phone_number)
    end
  end
end
