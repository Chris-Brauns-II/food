require 'rails_helper'

RSpec.describe Documents::Generation::FakeCommunicator do
  context "#generate_pdf_from_html" do
    subject do
      described_class.new.generate_pdf_from_html(document:, header:, footer:)
    end

    let(:document) { "<div>H1</div>" }
    let(:header) { "<div>H1</div>" }
    let(:footer) { "<div>H1</div>" }

    it "returns a real looking pdf" do
      expect(subject).to be_a(String)
    end
  end
end
