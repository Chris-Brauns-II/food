require 'rails_helper'

RSpec.describe Documents::DocumentsAggregator do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new }
  let(:resume_stream) { Documents::Streams::ResumeDocument.new(resume_document_id:) }
  let(:resume_document_id) { SecureRandom.uuid }
  let(:screener_stream) { Documents::Streams::ScreenerDocument.new(screener_document_id:) }
  let(:screener_document_id) { SecureRandom.uuid }
  let(:person_id) { SecureRandom.uuid }
  let(:screener_answers_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is generate resume for person" do
      let(:message) do
        build(
          :message,
          stream: resume_stream,
          schema: Documents::Events::ResumeGenerationRequested::V1,
          data: {
            person_id:,
            anonymized: true,
            document_kind: Documents::DocumentKind::PDF
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      it "creates a resume record" do
        expect { subject }.to change(Documents::Resume, :count).from(0).to(1)

        resume = Documents::Resume.first
        expect(resume.id).to eq(message.stream.id)
        expect(resume.id).to eq(message.stream.id)
        expect(resume.person_id).to eq(message.data.person_id)
        expect(resume.anonymized).to eq(message.data.anonymized)
        expect(resume.document_kind).to eq(message.data.document_kind)
        expect(resume.requestor_id).to eq(message.metadata.requestor_id)
        expect(resume.requestor_type).to eq(message.metadata.requestor_type)
        expect(resume.status).to eq(Documents::DocumentStatus::PROCESSING)
      end
    end

    context "when the message is resume generated" do
      let(:message) do
        build(
          :message,
          stream: resume_stream,
          schema: Documents::Events::ResumeGenerated::V1,
          data: {
            person_id:,
            anonymized: true,
            document_kind: Documents::DocumentKind::PDF,
            storage_kind: Documents::StorageKind::POSTGRES,
            storage_identifier: resume_document_id
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      let!(:resume) { create(:documents__resume, id: resume_document_id) }

      it "updates a resume record" do
        subject

        resume.reload
        expect(resume.storage_identifier).to eq(message.data.storage_identifier)
        expect(resume.storage_kind).to eq(message.data.storage_kind)
        expect(resume.document_generated_at).to eq(message.occurred_at)
        expect(resume.status).to eq(Documents::DocumentStatus::SUCCEEDED)
      end
    end

    context "when the message is resume generation failed" do
      let(:message) do
        build(
          :message,
          stream: resume_stream,
          schema: Documents::Events::ResumeGenerationFailed::V1,
          data: {
            person_id:,
            anonymized: true,
            document_kind: Documents::DocumentKind::PDF,
            reason: "no money"
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      let!(:resume) { create(:documents__resume, id: resume_document_id) }

      it "updates a resume record" do
        subject

        resume.reload
        expect(resume.status).to eq(Documents::DocumentStatus::FAILED)
      end
    end

    context "when the message is generate screener for answers" do
      let(:message) do
        build(
          :message,
          stream: screener_stream,
          schema: Documents::Events::ScreenerGenerationRequested::V1,
          data: {
            screener_answers_id:,
            document_kind: Documents::DocumentKind::PDF
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      it "creates a screener record" do
        expect { subject }.to change(Documents::Screener, :count).from(0).to(1)

        screener = Documents::Screener.first
        expect(screener.id).to eq(message.stream.id)
        expect(screener.screener_answers_id).to eq(message.data.screener_answers_id)
        expect(screener.document_kind).to eq(message.data.document_kind)
        expect(screener.requestor_id).to eq(message.metadata.requestor_id)
        expect(screener.requestor_type).to eq(message.metadata.requestor_type)
        expect(screener.status).to eq(Documents::DocumentStatus::PROCESSING)
      end
    end

    context "when the message is screener generated" do
      let(:message) do
        build(
          :message,
          stream: screener_stream,
          schema: Documents::Events::ScreenerGenerated::V1,
          data: {
            person_id:,
            screener_answers_id:,
            document_kind: Documents::DocumentKind::PDF,
            storage_kind: Documents::StorageKind::POSTGRES,
            storage_identifier: resume_document_id
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      let!(:screener) { create(:documents__screener, id: screener_document_id) }

      it "updates a screener record" do
        subject

        screener.reload
        expect(screener.storage_identifier).to eq(message.data.storage_identifier)
        expect(screener.storage_kind).to eq(message.data.storage_kind)
        expect(screener.document_generated_at).to eq(message.occurred_at)
        expect(screener.status).to eq(Documents::DocumentStatus::SUCCEEDED)
      end
    end

    context "when the message is screener generation failed" do
      let(:message) do
        build(
          :message,
          stream: screener_stream,
          schema: Documents::Events::ScreenerGenerationFailed::V1,
          data: {
            person_id:,
            screener_answers_id:,
            document_kind: Documents::DocumentKind::PDF,
            reason: "no money"
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: user_id
          }
        )
      end

      let!(:screener) { create(:documents__screener, id: screener_document_id) }

      it "updates a screener record" do
        subject

        screener.reload
        expect(screener.status).to eq(Documents::DocumentStatus::FAILED)
      end
    end
  end
end
