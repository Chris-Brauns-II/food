class EmployerWeeklyMailer < ApplicationMailer
  default from: 'admin@skillarc.com'

  def applicants
    @data = params[:message].data

    mail(
      to: @data.recepent_email,
      subject: 'Weekly Applicant Summary' # rubocop:disable Rails/I18nLocaleTexts
    )
  end
end
