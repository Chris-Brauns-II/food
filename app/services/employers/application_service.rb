module Employers
  class ApplicationService
    def self.update_status(message_service:, status:, user_id:, application_id:, reasons: [])
      applicant_status_updated = ::Projectors::Streams::GetLast.project(
        stream: Streams::Application.new(application_id:),
        schema: Events::ApplicantStatusUpdated::V6
      )

      message_service.create!(
        schema: Events::ApplicantStatusUpdated::V6,
        application_id:,
        data: {
          **applicant_status_updated.data.to_h,
          status:,
          reasons: reasons.map do |reason|
            Events::ApplicantStatusUpdated::Reason::V2.new(
              id: reason[:id],
              response: reason[:response],
              reason_description: Employers::PassReason.find(reason[:id]).description
            )
          end
        },
        metadata: {
          user_id:
        }
      )
    end
  end
end
