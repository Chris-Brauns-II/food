require 'rails_helper'

RSpec.describe Documents::Storage::DbCommunicator do
  let(:instance) { described_class.new }

  describe "#store_document" do
    subject { instance.store_document(id:, file_data:, file_name:) }

    let(:id) { "123" }
    let(:file_name) { "file.txt" }
    let(:file_data) { "\xDE\xAD\xBE\xEF".force_encoding('ASCII-8BIT') }

    it "creates a document" do
      expect do
        expect(subject.storage_kind).to eq(Documents::StorageKind::POSTGRES)
        expect(subject.storage_identifier).to eq(id)
      end.to change(Document, :count).from(0).to(1)

      document = Document.first
      expect(document.id).to eq(id)
      expect(document.file_name).to eq(file_name)
      expect(document.file_data).to eq(file_data)
    end
  end

  describe "#retrieve_document" do
    subject { instance.retrieve_document(identifier:) }

    let(:document) { create(:document) }

    let(:identifier) { document.id }

    it "calls db communicator with the same args" do
      expect(subject.file_name).to eq(document.file_name)
      expect(subject.file_data).to eq(document.file_data)
      expect(subject.stored_at).to eq(document.created_at)
    end
  end
end
