require 'rails_helper'

RSpec.describe Attributes::AttributesReactor do
  it_behaves_like "a non replayable message consumer"

  let(:message_service) { MessageService.new }
  let(:consumer) { described_class.new(message_service:) }

  describe ".create" do
    subject { consumer.create(attribute_id:, name:, description:, set:, default:) }

    let(:name) { "name" }
    let(:description) { "description" }
    let(:set) { %w[A B] }
    let(:default) { ["B"] }
    let(:attribute_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::AttributeCreated::V1,
        attribute_id:,
        data: {
          name:,
          description:,
          set:,
          default:
        }
      )

      subject
    end
  end

  describe ".update" do
    subject { consumer.update(attribute_id:, name:, description:, set:, default:) }

    let(:name) { "name" }
    let(:description) { "description" }
    let(:set) { %w[A B] }
    let(:default) { ["B"] }
    let(:attribute_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::AttributeUpdated::V1,
        attribute_id:,
        data: {
          name:,
          description:,
          set:,
          default:
        }
      )

      subject
    end
  end

  describe ".destroy" do
    subject { consumer.destroy(attribute_id:) }

    let(:attribute_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::AttributeDeleted::V1,
        attribute_id:,
        data: Core::Nothing
      )

      subject
    end
  end
end
