module Documents
  class ScreenersController < ApplicationController
    include Secured
    include MessageEmitter

    UnknownDocumentTypeError = Class.new(StandardError)

    before_action :authorize
    before_action :screener_authorize

    def index
      render json: DocumentsQuery.all_screeners(person_id: params[:person_id])
    end

    def show
      resume = Screener.find(params[:id])

      document = Storage::Gateway.build.retrieve_document(
        storage_kind: resume.storage_kind,
        identifier: resume.storage_identifier
      )

      send_data document.file_data, filename: document.file_name, type: document_mime_type(resume.document_kind)
    end

    def create
      with_message_service do
        message_service.create!(
          trace_id: request.request_id,
          screener_document_id: SecureRandom.uuid,
          schema: Documents::Commands::GenerateScreenerForAnswers::V1,
          data: {
            screener_answers_id: params[:screener_answers_id],
            document_kind: Documents::DocumentKind::PDF
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: current_user.id,
            requestor_email: current_user.email
          }
        )
      end

      head :accepted
    end

    private

    def screener_authorize
      return if current_user.job_order_admin_role? || current_user.coach_role?

      render json: { error: 'Not authorized' }, status: :unauthorized
      nil
    end

    def document_mime_type(document_kind)
      case document_kind
      when Documents::DocumentKind::PDF
        'application/pdf'
      else
        raise UnknownDocumentTypeError, document_kind
      end
    end
  end
end
