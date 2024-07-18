require 'rails_helper'

RSpec.describe Jobs::Projectors::Attributes do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:messages) do
      [
        job_attribute_created1,
        job_attribute_created2,
        job_attribute_updated2,
        job_attribute_destoryed1
      ]
    end

    let(:job_id) { SecureRandom.uuid }
    let(:id1) { SecureRandom.uuid }
    let(:id2) { SecureRandom.uuid }
    let(:id3) { SecureRandom.uuid }
    let(:id4) { SecureRandom.uuid }

    let(:job_attribute_created1) do
      build(
        :message,
        schema: Events::JobAttributeCreated::V1,
        stream_id: job_id,
        data: {
          id: id1,
          attribute_id: id3,
          attribute_name: "Name1",
          acceptible_set: %w[A B]
        }
      )
    end
    let(:job_attribute_created2) do
      build(
        :message,
        schema: Events::JobAttributeCreated::V1,
        stream_id: job_id,
        data: {
          id: id2,
          attribute_id: id4,
          attribute_name: "Name2",
          acceptible_set: %w[C]
        }
      )
    end
    let(:job_attribute_updated2) do
      build(
        :message,
        schema: Events::JobAttributeUpdated::V1,
        stream_id: job_id,
        data: {
          id: id2,
          acceptible_set: %w[D F]
        }
      )
    end
    let(:job_attribute_destoryed1) do
      build(
        :message,
        schema: Events::JobAttributeDestroyed::V1,
        stream_id: job_id,
        data: {
          id: id1
        }
      )
    end

    it "returns the job attributes" do
      expect(subject.attributes).to eq({ id2 =>
        described_class::Attribute.new(
          name: "Name2",
          id: id4,
          acceptible_set: %w[D F]
        ) })
    end
  end
end
