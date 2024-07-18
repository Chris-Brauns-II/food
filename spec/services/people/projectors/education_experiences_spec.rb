require 'rails_helper'

RSpec.describe People::Projectors::EducationExperiences do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Person.new(person_id:) }
    let(:person_id) { SecureRandom.uuid }
    let(:education_experience_id1) { SecureRandom.uuid }
    let(:education_experience_id2) { SecureRandom.uuid }

    let(:messages) do
      [
        education_experience_added1,
        education_experience_added2,
        education_experience_added3,
        education_experience_removed1
      ]
    end

    let(:education_experience_added1) do
      build(
        :message,
        stream:,
        schema: Events::EducationExperienceAdded::V2,
        data: {
          id: education_experience_id1,
          organization_name: "1",
          title: "1",
          graduation_date: "1",
          activities: "1",
          gpa: "1"
        }
      )
    end
    let(:education_experience_added2) do
      build(
        :message,
        stream:,
        schema: Events::EducationExperienceAdded::V2,
        data: {
          id: education_experience_id1,
          organization_name: "2",
          title: "2",
          graduation_date: "2",
          activities: "2",
          gpa: "2"
        }
      )
    end
    let(:education_experience_added3) do
      build(
        :message,
        stream:,
        schema: Events::EducationExperienceAdded::V2,
        data: {
          id: education_experience_id2,
          organization_name: "3",
          title: "3",
          graduation_date: "3",
          activities: "3",
          gpa: "3"
        }
      )
    end
    let(:education_experience_removed1) do
      build(
        :message,
        stream:,
        schema: Events::EducationExperienceDeleted::V2,
        data: {
          id: education_experience_id2
        }
      )
    end

    it "projects the education experience" do
      expect(subject.education_experiences.length).to eq(1)
      expect(subject.education_experiences[education_experience_id1]).to eq(
        described_class::EducationExperience.new(
          organization_name: "2",
          title: "2",
          graduation_date: "2",
          activities: "2",
          gpa: "2"
        )
      )
    end
  end
end
