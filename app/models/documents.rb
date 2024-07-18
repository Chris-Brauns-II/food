# frozen_string_literal: true

module Documents
  def self.table_name_prefix
    "documents_"
  end

  module Checks
    ALL = [
      BACKGROUND = "background",
      DRUG = "drug"
    ].freeze
  end

  module DocumentStatus
    ALL = [
      PROCESSING = "processing",
      SUCCEEDED = "succeeded",
      FAILED = "failed"
    ].freeze
  end

  module StorageKind
    ALL = [
      POSTGRES = "postgres"
    ].freeze
  end

  module DocumentKind
    ALL = [
      PDF = "pdf"
    ].freeze
  end
end
