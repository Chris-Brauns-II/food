require 'rails_helper'

RSpec.describe Documents::DocumentsQuery do
  describe ".all_resumes" do
    subject { described_class.all_resumes(requestor_id:, person_id:) }

    let(:p_id) { SecureRandom.uuid }
    let(:r_id) { SecureRandom.uuid }

    let!(:resume1) { create(:documents__resume, requestor_id: r_id, person_id: p_id, status: Documents::DocumentStatus::SUCCEEDED, document_generated_at: Time.zone.local(2023, 1, 1)) }
    let!(:resume2) { create(:documents__resume, requestor_id: SecureRandom.uuid, person_id: p_id) }
    let!(:resume3) { create(:documents__resume, requestor_id: r_id, person_id: SecureRandom.uuid) }

    let(:serialized_resume1) do
      {
        id: resume1.id,
        anonymized: resume1.anonymized,
        document_status: resume1.status,
        generated_at: resume1.document_generated_at,
        document_kind: resume1.document_kind,
        person_id: resume1.person_id
      }
    end
    let(:serialized_resume2) do
      {
        id: resume2.id,
        anonymized: resume2.anonymized,
        document_status: resume2.status,
        generated_at: resume2.document_generated_at,
        document_kind: resume2.document_kind,
        person_id: resume2.person_id
      }
    end
    let(:serialized_resume3) do
      {
        id: resume3.id,
        anonymized: resume3.anonymized,
        document_status: resume3.status,
        generated_at: resume3.document_generated_at,
        document_kind: resume3.document_kind,
        person_id: resume3.person_id
      }
    end

    context "when person_id and requestor_id are nil" do
      let(:person_id) { nil }
      let(:requestor_id) { nil }

      it "returns each resume" do
        expect(subject).to contain_exactly(
          serialized_resume1,
          serialized_resume2,
          serialized_resume3
        )
      end
    end

    context "when person_id is provided" do
      let(:person_id) { p_id }
      let(:requestor_id) { nil }

      it "returns each resume for that person" do
        expect(subject).to contain_exactly(
          serialized_resume1,
          serialized_resume2
        )
      end
    end

    context "when requestor_id is provided" do
      let(:person_id) { nil }
      let(:requestor_id) { r_id }

      it "returns each resume for that person" do
        expect(subject).to contain_exactly(
          serialized_resume1,
          serialized_resume3
        )
      end
    end

    context "when both person_id and requestor_id is provided" do
      let(:person_id) { p_id }
      let(:requestor_id) { r_id }

      it "returns each resume for that person" do
        expect(subject).to contain_exactly(
          serialized_resume1
        )
      end
    end
  end

  describe ".all_screeners" do
    subject { described_class.all_screeners(person_id:) }

    let(:p_id) { SecureRandom.uuid }
    let(:r_id) { SecureRandom.uuid }

    let!(:screener1) { create(:documents__screener, person_id: p_id, status: Documents::DocumentStatus::SUCCEEDED, document_generated_at: Time.zone.local(2023, 1, 1)) }
    let!(:screener2) { create(:documents__screener, person_id: SecureRandom.uuid) }

    let(:serialized_screener1) do
      {
        id: screener1.id,
        document_status: screener1.status,
        generated_at: screener1.document_generated_at,
        document_kind: screener1.document_kind,
        person_id: screener1.person_id
      }
    end
    let(:serialized_screener2) do
      {
        id: screener2.id,
        document_status: screener2.status,
        generated_at: screener2.document_generated_at,
        document_kind: screener2.document_kind,
        person_id: screener2.person_id
      }
    end

    context "when person_id and requestor_id are nil" do
      let(:person_id) { nil }

      it "returns each resume" do
        expect(subject).to contain_exactly(
          serialized_screener1,
          serialized_screener2
        )
      end
    end

    context "when person_id is provided" do
      let(:person_id) { p_id }

      it "returns each resume for that person" do
        expect(subject).to contain_exactly(
          serialized_screener1
        )
      end
    end
  end
end
