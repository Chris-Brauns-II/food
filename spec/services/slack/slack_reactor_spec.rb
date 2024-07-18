require 'rails_helper'

RSpec.describe Slack::SlackReactor do
  describe "#handle_message" do
    subject { described_class.new(client:, message_service:).handle_message(message) }

    let(:client) { Slack::FakeClient.new }
    let(:message_service) { MessageService.new }

    context "when the message is user_created" do
      let(:message) do
        build(
          :message,
          schema: Events::UserCreated::V1,
          stream_id: SecureRandom.uuid,
          data: {
            email:
          }
        )
      end
      let(:email) { "some@email.com" }

      it "sends a slack message to the #feed channel" do
        expect(client)
          .to receive(:chat_postMessage)
          .with(
            channel: '#feed',
            text: "New user signed up: *some@email.com*",
            as_user: true
          )

        subject
      end
    end

    context "when the message is applicant status updated" do
      let(:message) do
        build(
          :message,
          schema: Events::ApplicantStatusUpdated::V6,
          data: {
            applicant_first_name: "John",
            applicant_last_name: "Chabot",
            applicant_email: "john@skillarc.com",
            seeker_id: "d9956e79-c5f3-41c8-9150-9fa799e0f33f",
            user_id: SecureRandom.uuid,
            job_id: SecureRandom.uuid,
            employer_name: "Employer",
            employment_title: "A title",
            status:
          },
          metadata: {
            user_id: SecureRandom.uuid
          }
        )
      end

      context "when the applicant status is not new" do
        let(:status) { ApplicantStatus::StatusTypes::PASS }

        it "does not send a message" do
          expect(client)
            .not_to receive(:chat_postMessage)

          subject
        end
      end

      context "when the applicant status is new" do
        let(:status) { ApplicantStatus::StatusTypes::NEW }

        it "does not send a message" do
          expect(client)
            .to receive(:chat_postMessage)
            .with(
              channel: '#feed',
              text: "<#{ENV.fetch('FRONTEND_URL', nil)}/profiles/d9956e79-c5f3-41c8-9150-9fa799e0f33f|john@skillarc.com> has applied to *A title* at *Employer*",
              as_user: true
            )

          subject
        end
      end
    end

    context "when the message is chat message sent" do
      before do
        Event.from_message!(applicant_status_updated)
      end

      let(:applicant_status_updated) do
        build(
          :message,
          stream_id: application_id,
          schema: Events::ApplicantStatusUpdated::V6,
          data: {
            applicant_first_name: "John",
            applicant_last_name: "Chabot",
            applicant_email: "some@email.com",
            seeker_id:,
            user_id: SecureRandom.uuid,
            job_id: SecureRandom.uuid,
            employer_name: "Employer",
            employment_title: "A job",
            status: ApplicantStatus::StatusTypes::NEW
          },
          metadata: {
            user_id: SecureRandom.uuid
          }
        )
      end

      let(:message) do
        build(
          :message,
          stream_id: application_id,
          schema: Events::ChatMessageSent::V2,
          data: {
            from_name: "Yo Boi",
            from_user_id:,
            message: "yo"
          }
        )
      end

      let(:application_id) { SecureRandom.uuid }
      let(:seeker_id) { SecureRandom.uuid }

      context "when the from_user_id is the seeker" do
        let(:from_user_id) { applicant_status_updated.data.user_id }

        it "sends a slack message to the #feed channel" do
          expect(client)
            .to receive(:chat_postMessage)
            .with(
              channel: '#feed',
              text: "Applicant <#{ENV.fetch('FRONTEND_URL', nil)}/profiles/#{seeker_id}|some@email.com> has *sent* a message to *Employer* for their applcation to *A job*.",
              as_user: true
            )

          subject
        end
      end

      context "when the from_user_id is not the seeker" do
        let(:from_user_id) { SecureRandom.uuid }

        it "sends a slack message to the #feed channel" do
          expect(client)
            .to receive(:chat_postMessage)
            .with(
              channel: '#feed',
              text: "Applicant <#{ENV.fetch('FRONTEND_URL', nil)}/profiles/#{seeker_id}|some@email.com> has *received* a message from *Employer* for their applcation to *A job*.",
              as_user: true
            )

          subject
        end
      end
    end

    context "wehn the message is send slack message" do
      let(:message) do
        build(
          :message,
          schema: Commands::SendSlackMessage::V2,
          data: {
            channel: "#somechannel",
            text: "*some text*",
            blocks: nil
          }
        )
      end

      it "sends a slack message to the provided channel and emits and event" do
        expect(message_service)
          .to receive(:create_once_for_stream!)
          .with(
            schema: Events::SlackMessageSent::V2,
            trace_id: message.trace_id,
            message_id: message.stream.message_id,
            data: {
              channel: "#somechannel",
              text: "*some text*",
              blocks: nil
            }
          )

        expect(client)
          .to receive(:chat_postMessage)
          .with(
            channel: '#somechannel',
            text: "*some text*",
            blocks: nil,
            as_user: true
          )

        subject
      end
    end
  end
end
