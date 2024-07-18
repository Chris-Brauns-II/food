require 'rails_helper'

RSpec.describe Employers::Projectors::Name do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Employer.new(employer_id:) }
    let(:employer_id) { SecureRandom.uuid }

    let(:employer_created) do
      build(
        :message,
        stream:,
        schema: Events::EmployerCreated::V1,
        data: {
          name: "Employer",
          location: "Place",
          bio: "An employer",
          logo_url: "www.google.com"
        }
      )
    end
    let(:employer_update) do
      build(
        :message,
        stream:,
        schema: Events::EmployerUpdated::V1,
        data: {
          name: "Employer2",
          location: "Place",
          bio: "An employer",
          logo_url: "www.google.com"
        }
      )
    end

    let(:messages) { [employer_created, employer_update] }

    it "determines the current name" do
      expect(subject.name).to eq(employer_update.data.name)
    end
  end
end
