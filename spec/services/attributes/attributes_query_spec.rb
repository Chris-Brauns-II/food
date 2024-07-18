require 'rails_helper'

RSpec.describe Attributes::AttributesQuery do
  describe ".all" do
    subject { described_class.all }

    let!(:attribute) { create(:attributes_attribute) }

    it "returns all attributes" do
      expect(subject).to eq(Attributes::Attribute.all)
    end
  end

  describe ".find" do
    subject { described_class.find(attribute_id) }

    let!(:attribute) { create(:attributes_attribute) }
    let(:attribute_id) { attribute.id }

    it "returns the attribute" do
      expect(subject).to eq(attribute)
    end
  end
end
