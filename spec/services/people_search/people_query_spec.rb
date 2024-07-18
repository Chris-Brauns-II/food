require 'rails_helper'

RSpec.describe PeopleSearch::PeopleQuery do
  describe ".search" do
    subject do
      instance.search(
        search_terms:,
        attributes:,
        user:,
        utm_source:
      )
    end
    let(:instance) { described_class.new }
    let(:search_terms) { "john chabot" }
    let(:attributes) { nil }
    let(:user) { create(:user) }
    let(:utm_source) { nil }

    let!(:person) do
      create(
        :people_search_person,
        search_vector: "John Chabot 555-555-5555 john.chabot@skillarc.com"
      )
    end

    it "returns a list of people" do
      expect(subject).to contain_exactly(person)
    end

    it "emits an event" do
      expect_any_instance_of(MessageService)
        .to receive(:create!)
        .with(
          schema: Events::PersonSearchExecuted::V1,
          person_search_id: user.id,
          data: {
            search_terms:,
            attributes: {}
          }
        ).and_call_original

      subject
    end
  end
end
