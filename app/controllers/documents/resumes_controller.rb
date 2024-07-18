module Documents
  class ResumesController < ApplicationController
    include Secured
    include MessageEmitter

    UnknownDocumentTypeError = Class.new(StandardError)

    before_action :authorize

    def index
      if can_see_all_resumes?
        render json: DocumentsQuery.all_resumes(person_id: params[:person_id])
      else
        render json: DocumentsQuery.all_resumes(person_id: params[:person_id], requestor_id: current_user.id)
      end
    end

    def show
      resume = Resume.find(params[:id])

      # A user can download resumes they generated
      # A coach or a job admin can download all resumes
      if resume.requestor_id == current_user.id || can_see_all_resumes?
        document = Storage::Gateway.build.retrieve_document(
          storage_kind: resume.storage_kind,
          identifier: resume.storage_identifier
        )

        send_data document.file_data, filename: document.file_name, type: document_mime_type(resume.document_kind)
      else
        render json: Secured::REQUIRES_AUTHENTICATION, status: :unauthorized
      end
    end

    def create
      person_id = params[:person_id]

      # A user can create a resume for themselves
      # A coach or job admin can create for anyone
      if current_user.person_id == person_id || can_see_all_resumes?
        with_message_service do
          message_service.create!(
            trace_id: request.request_id,
            resume_document_id: SecureRandom.uuid,
            schema: Commands::GenerateResumeForPerson::V2,
            data: {
              person_id:,
              checks: params[:checks] || [],
              anonymized: params[:anonymized] || false,
              document_kind: params[:document_kind] || DocumentKind::PDF,
              page_limit: params[:page_limit] || 1
            },
            metadata: {
              requestor_type: Requestor::Kinds::USER,
              requestor_id: current_user.id
            }
          )
        end

        head :created
      else
        render json: Secured::REQUIRES_AUTHENTICATION, status: :unauthorized
      end
    end

    private

    def document_mime_type(document_kind)
      case document_kind
      when Documents::DocumentKind::PDF
        'application/pdf'
      else
        raise UnknownDocumentTypeError, document_kind
      end
    end

    def can_see_all_resumes?
      current_user.job_order_admin_role? || current_user.coach_role?
    end
  end
end
