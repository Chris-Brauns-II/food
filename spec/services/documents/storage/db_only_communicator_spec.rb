require 'rails_helper'

RSpec.describe Documents::Storage::DbOnlyCommunicator do
  let(:instance) { described_class.new }

  describe "#store_document" do
    subject { instance.store_document(storage_kind:, id:, file_data:, file_name:) }

    let(:storage_kind) { Documents::StorageKind::POSTGRES }
    let(:id) { "123" }
    let(:file_name) { "file.txt" }
    let(:file_data) { "\xDE\xAD\xBE\xEF" }

    it "calls db communicator with the same args" do
      expect_any_instance_of(Documents::Storage::DbCommunicator)
        .to receive(:store_document)
        .with(
          id:,
          file_data:,
          file_name:
        )
        .and_call_original

      subject
    end
  end

  describe "#retrieve_document" do
    subject { instance.retrieve_document(storage_kind:, identifier:) }

    let(:storage_kind) { Documents::StorageKind::POSTGRES }
    let(:identifier) { "123" }

    it "calls db communicator with the same args" do
      expect_any_instance_of(Documents::Storage::DbCommunicator)
        .to receive(:retrieve_document)
        .with(
          identifier:
        )

      subject
    end
  end
end
