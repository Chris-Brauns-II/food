require 'rails_helper'

RSpec.describe Contact::SmtpReactor do
  it_behaves_like "a non replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new(message_service: MessageService.new).handle_message(message) }

    context "when the message is Commands::NotifyEmployerOfApplicant::V1" do
      let(:message) do
        build(
          :message,
          schema: Commands::NotifyEmployerOfApplicant::V1,
          data: {
            employment_title: "Job Title",
            recepent_email: "recruiter@skillarc.com",

            certified_by: "chris@skillarc.com",
            applicant_first_name: "John",
            applicant_last_name: "Chabot",
            applicant_email: "applicant@a.com",
            applicant_phone_number: "1 555 555 5555",
            applicant_seeker_id: "47407410-d0df-4045-b2d8-20c9f03b6b55"
          }
        )
      end

      it "sends an email" do
        expect(EmployerApplicantNotificationMailer)
          .to receive(:with)
          .with(message:)
          .and_call_original

        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_call_original

        subject
      end

      it "publishes an event" do
        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::SmtpSent::V1,
          contact: "recruiter@skillarc.com",
          trace_id: message.trace_id,
          data: {
            email: "recruiter@skillarc.com",
            template: EmployerApplicantNotificationMailer.class.to_s,
            template_data: {
              employment_title: "Job Title",
              recepent_email: "recruiter@skillarc.com",

              certified_by: "chris@skillarc.com",
              applicant_first_name: "John",
              applicant_last_name: "Chabot",
              applicant_email: "applicant@a.com",
              applicant_phone_number: "1 555 555 5555",
              applicant_seeker_id: "47407410-d0df-4045-b2d8-20c9f03b6b55"
            }
          }
        )

        subject
      end
    end

    context "when the message is Commands::SendWeeklyEmployerUpdate::V1" do
      let(:message) do
        build(
          :message,
          schema: Commands::SendWeeklyEmployerUpdate::V1,
          data: {
            employer_name: "Employer Name",
            recepent_email: "foo@bar.baz",
            new_applicants: [
              Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
                first_name: "First",
                last_name: "Last"
              )
            ],
            pending_applicants: [
              Commands::SendWeeklyEmployerUpdate::SummaryApplicant::V1.new(
                first_name: "John",
                last_name: "Chabot",
                certified_by: "chris@skillarc.com"
              )
            ]
          }
        )
      end

      it "sends an email" do
        expect(EmployerWeeklyMailer)
          .to receive(:with)
          .with(message:)
          .and_call_original

        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_call_original

        subject
      end

      it "publishes an event" do
        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::SmtpSent::V1,
          contact: "foo@bar.baz",
          trace_id: message.trace_id,
          data: {
            email: "foo@bar.baz",
            template: EmployerWeeklyMailer.class.to_s,
            template_data: {
              employer_name: "Employer Name",
              recepent_email: "foo@bar.baz",
              new_applicants: [
                {
                  first_name: "First",
                  last_name: "Last",
                  certified_by: nil
                }
              ],
              pending_applicants: [
                {
                  first_name: "John",
                  last_name: "Chabot",
                  certified_by: "chris@skillarc.com"
                }
              ]
            }
          }
        )

        subject
      end
    end

    context "when the message is Commands::SendEmailMessage::V1" do
      let(:message) do
        build(
          :message,
          schema: Commands::SendEmailMessage::V1,
          data: {
            recepent_email: "foo@bar.baz",
            title: "Reminder",
            body: "Do this thing now",
            url: nil
          }
        )
      end

      it "sends an email" do
        expect(MessageMailer)
          .to receive(:with)
          .with(message:)
          .and_call_original

        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_call_original

        subject
      end

      it "publishes events" do
        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::SmtpSent::V1,
          contact: "foo@bar.baz",
          trace_id: message.trace_id,
          data: {
            email: "foo@bar.baz",
            template: MessageMailer.class.to_s,
            template_data: {
              recepent_email: "foo@bar.baz",
              title: "Reminder",
              body: "Do this thing now",
              url: nil
            }
          }
        )

        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::EmailMessageSent::V1,
          message_id: message.stream.message_id,
          trace_id: message.trace_id,
          data: {
            recepent_email: "foo@bar.baz",
            title: "Reminder",
            body: "Do this thing now",
            url: nil
          }
        )

        subject
      end
    end
  end
end
