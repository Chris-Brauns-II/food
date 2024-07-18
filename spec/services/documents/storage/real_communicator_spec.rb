require 'rails_helper'

RSpec.describe Documents::Storage::RealCommunicator do
  let(:instance) { described_class.new }

  describe "#store_document" do
    subject { instance.store_document(storage_kind:, id:, file_data:, file_name:) }

    let(:id) { "123" }
    let(:file_name) { "file.txt" }
    let(:file_data) { "\xDE\xAD\xBE\xEF" }

    context "when the storage kind is postgres" do
      let(:storage_kind) { Documents::StorageKind::POSTGRES }

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

    context "when the storage kind is not implmented" do
      let(:storage_kind) { "something" }

      it "raises a UnknownStorageKindError" do
        expect { subject }.to raise_error(described_class::UnknownStorageKindError)
      end
    end
  end

  describe "#retrieve_document" do
    subject { instance.retrieve_document(storage_kind:, identifier:) }

    let(:identifier) { "123" }

    context "when the storage kind is postgres" do
      let(:storage_kind) { Documents::StorageKind::POSTGRES }

      it "calls db communicator with the same args" do
        expect_any_instance_of(Documents::Storage::DbCommunicator)
          .to receive(:retrieve_document)
          .with(
            identifier:
          )

        subject
      end
    end

    context "when the storage kind is not implmented" do
      let(:storage_kind) { "something" }

      it "raises a UnknownStorageKindError" do
        expect { subject }.to raise_error(described_class::UnknownStorageKindError)
      end
    end
  end
end
