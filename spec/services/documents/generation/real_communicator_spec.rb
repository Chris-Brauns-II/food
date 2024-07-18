require 'rails_helper'

RSpec.describe Documents::Generation::RealCommunicator do
  context "#generate_pdf_from_html" do
    subject do
      described_class.new(base_url:, auth:).generate_pdf_from_html(document:, header:, footer:)
    end

    let(:base_url) { "http://www.example.com:3002" }
    let(:auth) { ENV.fetch("PUPPETEER_AUTH", nil) }
    let(:document) { "<div>H1</div>" }
    let(:header) { "<div>H1</div>" }
    let(:footer) { "<div>H1</div>" }

    it "returns a real looking pdf" do
      http = Net::HTTP.new("www.example.com", 3002)
      response = instance_double('Net::HTTPResponse', code: '200', body: 'OK')

      expect(URI)
        .to receive(:parse)
        .with("http://www.example.com:3002/export/pdf")
        .and_call_original

      expect(Net::HTTP)
        .to receive(:new)
        .with("www.example.com", 3002)
        .and_return(http)

      expect(http)
        .to receive(:request)
        .with(be_a(Net::HTTP::Post))
        .and_return(response)

      expect(subject).to be_a(String)
    end
  end
end
