class MessageMailer < ApplicationMailer
  default from: 'admin@skillarc.com'

  def send_message
    @data = params[:message].data

    mail(
      to: @data.recepent_email,
      subject: @data.title
    )
  end
end
