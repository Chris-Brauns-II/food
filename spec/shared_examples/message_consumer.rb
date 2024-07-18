RSpec.shared_examples "a replayable message consumer" do
  describe "#reset_for_replay" do
    subject { described_class.new.reset_for_replay }

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end

  describe "#can_replay?" do
    subject { described_class.new.can_replay? }

    it "returns true" do
      expect(subject).to eq(true)
    end
  end
end

RSpec.shared_examples "a non replayable message consumer" do
  describe "#can_replay?" do
    subject { described_class.new.can_replay? }

    it "returns true" do
      expect(subject).to eq(false)
    end
  end
end
