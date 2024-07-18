require 'rails_helper'

RSpec.describe Core::Nothing do
  describe ".===" do
    it "is case equal to itself" do
      expect(described_class === described_class).to eq(true) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands,Style/CaseEquality
    end
  end

  describe ".serialize" do
    subject do
      described_class.serialize
    end

    it "returns a empty hash" do
      expect(subject).to eq({})
    end
  end

  describe ".deserialize" do
    subject do
      described_class.deserialize(hash)
    end

    let(:hash) { {} }

    it "returns a empty hash" do
      expect(subject).to eq(described_class)
    end
  end
end
