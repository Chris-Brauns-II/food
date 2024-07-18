require 'rails_helper'

RSpec.describe Documents::ResumeGenerationService do
  describe ".generate_from_command" do
    subject { described_class.generate_from_command(message:, gateway:) }

    let(:message) do
      build(
        :message,
        schema: Documents::Commands::GenerateResume::V3,
        data: {
          person_id: SecureRandom.uuid,
          anonymized: true,
          checks: [Documents::Checks::DRUG, Documents::Checks::BACKGROUND],
          bio: nil,
          email: "a@b.com",
          phone_number: "333-333-3333",
          work_experiences: [],
          education_experiences: [],
          document_kind: Documents::DocumentKind::PDF,
          first_name: "Skillz",
          last_name: "Bot",
          page_limit: 1
        },
        metadata: {
          requestor_type: Requestor::Kinds::USER,
          requestor_id: SecureRandom.uuid
        }
      )
    end

    let(:gateway) { Documents::Generation::FakeCommunicator.new }

    it "creates a pdf document" do
      expect(gateway)
        .to receive(:generate_pdf_from_html)
        .with(
          document: be_a(String),
          header: be_a(String),
          footer: be_a(String)
        )
        .and_call_original

      expect(subject).to be_a(String)
    end
  end
end
