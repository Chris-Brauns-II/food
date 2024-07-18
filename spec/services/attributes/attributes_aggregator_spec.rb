require 'rails_helper'

RSpec.describe Attributes::AttributesAggregator do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "AttributeCreated" do
      let(:message) do
        build(
          :message,
          schema: Events::AttributeCreated::V1,
          data: {
            name: "name",
            description: "description",
            set: %w[A B],
            default: ["B"]
          }
        )
      end

      it "creates an attribute" do
        expect { subject }.to change { Attributes::Attribute.count }.by(1)
      end
    end

    context "AttributeUpdated" do
      let(:message) do
        build(
          :message,
          schema: Events::AttributeUpdated::V1,
          stream_id: attribute.id,
          data: {
            name: "name",
            description: "description",
            set: %w[A B],
            default: ["B"]
          }
        )
      end

      let!(:attribute) { create(:attributes_attribute) }

      it "updates an attribute" do
        subject

        expect(attribute.reload.name).to eq("name")
        expect(attribute.set).to eq(%w[A B])
        expect(attribute.default).to eq(["B"])
      end
    end

    context "AttributeDeleted" do
      let(:message) do
        build(
          :message,
          schema: Events::AttributeDeleted::V1,
          stream_id: attribute.id
        )
      end

      let!(:attribute) { create(:attributes_attribute) }

      it "deletes an attribute" do
        expect { subject }.to change { Attributes::Attribute.count }.by(-1)
      end
    end
  end
end
