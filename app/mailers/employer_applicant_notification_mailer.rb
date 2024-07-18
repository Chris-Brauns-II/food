class EmployerApplicantNotificationMailer < ApplicationMailer
  default from: 'admin@skillarc.com'

  def notify_employer
    @data = params[:message].data

    mail(
      to: @data.recepent_email,
      subject: "New Applicant for #{@data.employment_title} - #{@data.applicant_first_name} #{@data.applicant_last_name}"
    )
  end
end
