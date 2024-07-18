# Preview all emails at http://localhost:3001/rails/mailers/employer_weekly
class EmployerWeeklyPreview < ActionMailer::Preview
  def applicants
    message = FactoryBot.build(
      :message,
      :send_weekly_employer_update,
      version: 1,
      data: {
        employer_name: Faker::Company.name,
        recepent_email: Faker::Internet.email,
        new_applicants: [
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            certified_by: "john@skillarc.com"
          ),
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name
          )
        ],
        pending_applicants: [
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            certified_by: "john@skillarc.com"
          ),
          Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name
          )
        ]
      }
    )

    EmployerWeeklyMailer.with(message:).applicants
  end
end
