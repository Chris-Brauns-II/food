require 'rails_helper'

RSpec.describe People::Projectors::WorkExperiences do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Person.new(person_id:) }
    let(:person_id) { SecureRandom.uuid }
    let(:work_experience_id1) { SecureRandom.uuid }
    let(:work_experience_id2) { SecureRandom.uuid }

    let(:messages) do
      [
        experience_added1,
        experience_added2,
        experience_added3,
        experience_removed
      ]
    end

    let(:experience_added1) do
      build(
        :message,
        stream:,
        schema: Events::ExperienceAdded::V2,
        data: {
          id: work_experience_id1,
          organization_name: "1",
          position: "1",
          start_date: "1",
          end_date: "1",
          description: "1",
          is_current: true
        }
      )
    end
    let(:experience_added2) do
      build(
        :message,
        stream:,
        schema: Events::ExperienceAdded::V2,
        data: {
          id: work_experience_id1,
          organization_name: "2",
          position: "2",
          start_date: "2",
          end_date: "2",
          description: "2",
          is_current: true
        }
      )
    end
    let(:experience_added3) do
      build(
        :message,
        stream:,
        schema: Events::ExperienceAdded::V2,
        data: {
          id: work_experience_id2,
          organization_name: "3",
          position: "3",
          start_date: "3",
          end_date: "3",
          description: "3",
          is_current: true
        }
      )
    end
    let(:experience_removed) do
      build(
        :message,
        stream:,
        schema: Events::ExperienceRemoved::V2,
        data: {
          id: work_experience_id2
        }
      )
    end

    it "projects the work experience" do
      expect(subject.work_experiences.length).to eq(1)
      expect(subject.work_experiences[work_experience_id1]).to eq(
        described_class::WorkExperience.new(
          organization_name: "2",
          position: "2",
          start_date: "2",
          end_date: "2",
          description: "2",
          is_current: true
        )
      )
    end
  end
end
