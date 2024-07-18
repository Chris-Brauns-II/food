require 'rails_helper'

RSpec.describe Jobs::Projectors::CareerPaths do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:messages) do
      [
        career_path_created,
        career_path_updated,
        career_path_created2,
        career_path_destroyed
      ]
    end

    let(:job_id) { SecureRandom.uuid }

    let(:career_path_created) do
      build(
        :message,
        schema: Events::CareerPathCreated::V1,
        stream_id: job_id,
        data: {
          id: SecureRandom.uuid,
          job_id:,
          title: "Software Engineer",
          lower_limit: "0",
          upper_limit: "10",
          order: 0
        }
      )
    end
    let(:career_path_updated) do
      build(
        :message,
        schema: Events::CareerPathUpdated::V1,
        stream_id: job_id,
        data: {
          id: career_path_created.data[:id],
          order: 1
        }
      )
    end
    let(:career_path_created2) do
      build(
        :message,
        schema: Events::CareerPathCreated::V1,
        stream_id: job_id,
        data: {
          id: SecureRandom.uuid,
          job_id:,
          title: "Software Engineer",
          lower_limit: "0",
          upper_limit: "10",
          order: 1
        }
      )
    end
    let(:career_path_destroyed) do
      build(
        :message,
        schema: Events::CareerPathDestroyed::V1,
        stream_id: job_id,
        data: {
          id: career_path_created2.data[:id]
        }
      )
    end

    it "returns the paths" do
      expect(subject.paths).to eq([described_class::Path.new(
        id: career_path_created.data[:id],
        title: career_path_created.data[:title],
        lower_limit: career_path_created.data[:lower_limit],
        upper_limit: career_path_created.data[:upper_limit],
        order: 1
      )])
    end
  end
end
