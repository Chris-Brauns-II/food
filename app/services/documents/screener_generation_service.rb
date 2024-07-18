module Documents
  module ScreenerGenerationService
    def self.generate_from_command(message:, gateway: Generation::Gateway.build)
      gateway.generate_pdf_from_html(
        document: ActionController::Base.render(
          template: 'screeners/screener',
          layout: 'layouts/pdf',
          assigns: {
            question_responses: message.data.question_responses
          }
        ),
        header: ActionController::Base.render(
          template: 'common/header'
        ),
        footer: ActionController::Base.render(
          template: 'common/footer'
        )
      )
    end
  end
end
