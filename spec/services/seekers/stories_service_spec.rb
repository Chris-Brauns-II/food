require 'rails_helper'

RSpec.describe Seekers::StoriesService do
  include_context "event emitter"

  let(:seeker) { create(:seeker) }

  describe "#create" do
    subject { described_class.new(seeker).create(prompt:, response:) }

    let(:prompt) { "This is a prompt" }
    let(:response) { "This is a response" }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::StoryCreated::V2,
        person_id: seeker.id,
        data: {
          id: kind_of(String),
          prompt: "This is a prompt",
          response: "This is a response"
        }
      ).and_call_original

      subject
    end
  end

  describe "#update" do
    subject { described_class.new(seeker).update(story:, prompt:, response:) }

    let(:story) { create(:story, seeker:) }
    let(:prompt) { "This is a new prompt" }
    let(:response) { "This is a new response" }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::StoryUpdated::V2,
        person_id: seeker.id,
        data: {
          id: story.id,
          prompt: "This is a new prompt",
          response: "This is a new response"
        }
      ).and_call_original

      subject
    end
  end

  describe "#destroy" do
    subject { described_class.new(seeker).destroy(story:) }

    let!(:story) { create(:story, seeker:) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::StoryDestroyed::V2,
        person_id: seeker.id,
        data: {
          id: story.id
        }
      ).and_call_original

      subject
    end
  end
end
