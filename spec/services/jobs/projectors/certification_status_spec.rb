require 'rails_helper'

RSpec.describe Jobs::Projectors::CertificationStatus do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:messages) do
      [
        desired_certifcation_created1,
        desired_certifcation_destory,
        desired_certifcation_created2
      ]
    end

    let(:job_id) { SecureRandom.uuid }
    let(:id) { SecureRandom.uuid }

    let(:desired_certifcation_created1) do
      build(
        :message,
        schema: Events::DesiredCertificationCreated::V1,
        stream_id: job_id,
        data: {
          id:,
          job_id:,
          master_certification_id: SecureRandom.uuid
        }
      )
    end
    let(:desired_certifcation_destory) do
      build(
        :message,
        schema: Events::DesiredCertificationDestroyed::V1,
        stream_id: job_id,
        data: {
          id:
        }
      )
    end
    let(:desired_certifcation_created2) do
      build(
        :message,
        schema: Events::DesiredCertificationCreated::V1,
        stream_id: job_id,
        data: {
          id: SecureRandom.uuid,
          job_id:,
          master_certification_id: SecureRandom.uuid
        }
      )
    end

    it "returns live certifications" do
      expect(subject.current_certifications).to eq({ desired_certifcation_created2.data.id => desired_certifcation_created2.data.master_certification_id })
    end
  end
end
