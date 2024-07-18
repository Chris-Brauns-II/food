module Documents
  module Generation
    class RealCommunicator
      def initialize(base_url: ENV.fetch("PUPPETEER_BASE_URL", nil), auth: ENV.fetch("PUPPETEER_AUTH", nil))
        @base_url = base_url
        @auth = auth
      end

      def generate_pdf_from_html(document:, header:, footer:)
        uri = URI.parse("#{@base_url}/export/pdf")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request['Authorization'] = "Bearer #{@auth}"

        request.body = { document:, header:, footer: }.to_json

        http.request(request).body
      end
    end
  end
end
