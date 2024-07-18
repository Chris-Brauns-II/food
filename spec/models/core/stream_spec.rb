require 'rails_helper'

RSpec.describe Core::Stream do
  let(:sub_klass) do
    Class.new(described_class) do
      id_name :test_id
    end
  end

  describe "initialize" do
    context "when the provide keyword arg is the id name" do
      it "creates an instance of the class" do
        expect(sub_klass.new(test_id: SecureRandom.uuid)).to be_a(sub_klass)
      end
    end

    context "when the provide keyword arg is not id name" do
      it "raises an ArgumentError" do
        expect { sub_klass.new(other_id: SecureRandom.uuid) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#==" do
    context "when two streams have the same id and class" do
      it "they are equal" do
        expect(sub_klass.new(test_id: "1")).to eq(sub_klass.new(test_id: "1"))
      end
    end

    context "when two streams have the same id but different classes" do
      let(:sub_klass2) do
        Class.new(described_class) do
          id_name :test_id
        end
      end

      it "they are not equal" do
        expect(sub_klass.new(test_id: "1")).not_to eq(sub_klass2.new(test_id: "1"))
      end
    end

    context "when two streams have different ids but the classes" do
      it "they are not equal" do
        expect(sub_klass.new(test_id: "1")).not_to eq(sub_klass.new(test_id: "2"))
      end
    end
  end

  describe "#id" do
    it "returns the id" do
      expect(sub_klass.new(test_id: "1").id).to eq("1")
    end
  end

  describe "#to_s" do
    it "returns a human readable string" do
      expect(sub_klass.new(test_id: "1").to_s).to eq("#< test_id: 1>")
      # Note class name is missing because of anonymous class
    end
  end

  describe "#serialize" do
    it "returns the id" do
      expect(sub_klass.new(test_id: "1").serialize).to eq("1")
    end
  end

  describe "dynamic id method" do
    it "returns the id" do
      expect(sub_klass.new(test_id: "1").test_id).to eq("1")
    end
  end

  describe ".deserialize" do
    it "returns the stream from a string" do
      result = sub_klass.deserialize("1")
      expect(result).to be_a(sub_klass)
      expect(result.id).to eq("1")
    end
  end

  describe ".id" do
    it "symbol for the id column" do
      expect(sub_klass.id).to eq(:test_id)
    end
  end
end
