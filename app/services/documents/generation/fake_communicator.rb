module Documents
  module Generation
    class FakeCommunicator
      def generate_pdf_from_html(document:, header:, footer:) # rubocop:disable Lint/UnusedMethodArgument
        File.read('app/services/documents/generation/fake-document.pdf')
      end
    end
  end
end
