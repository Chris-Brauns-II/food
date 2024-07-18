require 'rails_helper'

RSpec.describe Documents::ScreenerGenerationService do
  describe ".generate_from_command" do
    subject { described_class.generate_from_command(message:, gateway:) }

    let(:message) do
      build(
        :message,
        schema: Documents::Commands::GenerateScreener::V1,
        data: {
          screener_answers_id: SecureRandom.uuid,

          question_responses: [
            Screeners::QuestionResponse.new(
              question: "Dude?",
              response: "Bro..."
            )
          ],
          document_kind: Documents::DocumentKind::PDF
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
