require 'rails_helper'

RSpec.describe JobOrders::Projectors::JobOrderCriteriaMet do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:messages) { [] }
    let(:stream) { Streams::Job.new(job_id:) }
    let(:job_id) { SecureRandom.uuid }

    let(:now) { Time.zone.now }

    let(:job_created) do
      build(
        :message,
        schema: Events::JobCreated::V3,
        stream_id: job_id,
        data: {
          category: Job::Categories::MARKETPLACE,
          employment_title: "A title",
          employer_name: "An employer",
          employer_id: SecureRandom.uuid,
          benefits_description: "Benifits",
          responsibilities_description:,
          requirements_description:,
          location: "Columbus Ohio",
          employment_type: Job::EmploymentTypes::FULLTIME,
          hide_job: false
        }
      )
    end
    let(:job_attribute_created) do
      build(
        :message,
        schema: Events::JobAttributeCreated::V1,
        stream:,
        data: {
          id: SecureRandom.uuid,
          attribute_id: SecureRandom.uuid,
          attribute_name: "Name1",
          acceptible_set: %w[A B]
        }
      )
    end

    let(:responsibilities_description) { "responsibilities" }
    let(:requirements_description) { "requirements" }

    context "when some descriptions are missing" do
      let(:messages) do
        [
          job_created,
          job_attribute_created
        ]
      end

      context "when responsbilities are missing" do
        let(:responsibilities_description) { nil }

        it "returns false" do
          expect(subject).to eq(false)
        end
      end

      context "when requirements are missing" do
        let(:requirements_description) { nil }

        it "returns false" do
          expect(subject).to eq(false)
        end
      end
    end

    context "when there are no attributes" do
      let(:messages) { [job_created] }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when attributes and descriptions are present" do
      let(:messages) do
        [
          job_created,
          job_attribute_created
        ]
      end

      it "returns true" do
        expect(subject).to eq(true)
      end
    end
  end
end
