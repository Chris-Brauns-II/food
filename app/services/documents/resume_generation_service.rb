module Documents
  module ResumeGenerationService
    def self.generate_from_command(message:, gateway: Generation::Gateway.build)
      gateway.generate_pdf_from_html(
        document: ActionController::Base.render(
          template: message.data.anonymized ? 'resumes/anonymous_resume' : 'resumes/resume',
          layout: 'layouts/pdf',
          assigns: {
            first_name: message.data.first_name,
            last_name: message.data.last_name,
            checks: message.data.checks,
            bio: message.data.bio,
            email: message.data.email,
            phone_number: message.data.phone_number,
            work_experiences: message.data.work_experiences,
            education_experiences: message.data.education_experiences
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

    def self.format_work_date(experience)
      if experience.start_date.present?
        if experience.is_current
          "#{experience.start_date} - Present"
        elsif experience.end_date.present?
          "#{experience.start_date} - #{experience.end_date}"
        else
          ""
        end
      elsif experience.is_current
        "Current"
      else
        ""
      end
    end
  end
end
