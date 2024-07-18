# Preview all emails at http://localhost:3001/rails/mailers/employer_applicant_notification_mailer
class EmployerApplicantNotificationMailerPreview < ActionMailer::Preview
  def notify_employer
    message = FactoryBot.build(
      :message,
      :notify_employer_of_applicant,
      version: 1,
      data: {
        employment_title: Faker::Job.title,
        recepent_email: Faker::Internet.email,

        certified_by: "john@skillarc.com",
        applicant_first_name: Faker::Name.first_name,
        applicant_last_name: Faker::Name.last_name,
        applicant_seeker_id: SecureRandom.uuid,
        applicant_email: "applicant@skillarc.com",
        applicant_phone_number: "1 555 555 5555"
      }
    )

    EmployerApplicantNotificationMailer.with(message:).notify_employer
  end
end
