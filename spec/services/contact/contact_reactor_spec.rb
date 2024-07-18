require 'rails_helper'

RSpec.describe Contact::ContactReactor do
  it_behaves_like "a non replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new(message_service:).handle_message(message) }

    let(:message_service) { MessageService.new }

    context "when the message is send message" do
      before do
        allow_any_instance_of(Contact::Projectors::ContactPreference)
          .to receive(:project)
          .and_return(projection)
      end

      let(:message) do
        build(
          :message,
          schema: Commands::SendMessage::V2,
          data: {
            title: "A title",
            body: "A body",
            url:,
            person_id:
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end
      let(:person_id) { SecureRandom.uuid }

      context "when the user prefers slack" do
        let(:projection) do
          Contact::Projectors::ContactPreference::Projection.new(
            phone_number: nil,
            email: nil,
            slack_id: SecureRandom.uuid,
            notification_user_id: nil,
            requested_preference: Contact::ContactPreference::SLACK
          )
        end

        context "when a url is present" do
          let(:url) { "www.google.com" }

          it "fires off a send slack message command" do
            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Commands::SendSlackMessage::V2,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: {
                  channel: projection.slack_id,
                  text: "*A title*: A body <www.google.com|Link>"
                }
              ).and_call_original

            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Events::MessageEnqueued::V1,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: Core::Nothing
              ).and_call_original

            subject
          end
        end

        context "when a url is absent" do
          let(:url) { nil }

          it "fires off a send slack message command" do
            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Commands::SendSlackMessage::V2,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: {
                  channel: projection.slack_id,
                  text: "*A title*: A body"
                }
              ).and_call_original

            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Events::MessageEnqueued::V1,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: Core::Nothing
              ).and_call_original

            subject
          end
        end
      end

      context "when the user prefers email" do
        let(:projection) do
          Contact::Projectors::ContactPreference::Projection.new(
            phone_number: nil,
            email: "a@b.c",
            slack_id: nil,
            notification_user_id: nil,
            requested_preference: Contact::ContactPreference::EMAIL
          )
        end
        let(:url) { "www.google.com" }

        it "fires off a send email message command" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Commands::SendEmailMessage::V1,
              trace_id: message.trace_id,
              message_id: message.stream.message_id,
              data: {
                recepent_email: projection.email,
                title: message.data.title,
                body: message.data.body,
                url: message.data.url
              }
            ).and_call_original

          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::MessageEnqueued::V1,
              trace_id: message.trace_id,
              message_id: message.stream.message_id,
              data: Core::Nothing
            ).and_call_original

          subject
        end
      end

      context "when the user prefers sms" do
        let(:projection) do
          Contact::Projectors::ContactPreference::Projection.new(
            phone_number: "777-777-7777",
            email: nil,
            slack_id: nil,
            notification_user_id: nil,
            requested_preference: Contact::ContactPreference::SMS
          )
        end

        context "when a url is present" do
          let(:url) { "www.google.com" }

          it "fires off a send sms message command" do
            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Commands::SendSmsMessage::V3,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: {
                  phone_number: projection.phone_number,
                  message: "A title: A body www.google.com"
                }
              ).and_call_original

            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Events::MessageEnqueued::V1,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: Core::Nothing
              ).and_call_original

            subject
          end
        end

        context "when a url is absent" do
          let(:url) { nil }

          it "fires off a send sms message command" do
            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Commands::SendSmsMessage::V3,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: {
                  phone_number: projection.phone_number,
                  message: "A title: A body"
                }
              ).and_call_original

            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Events::MessageEnqueued::V1,
                trace_id: message.trace_id,
                message_id: message.stream.message_id,
                data: Core::Nothing
              ).and_call_original

            subject
          end
        end
      end

      context "when the user prefers notification" do
        let(:projection) do
          Contact::Projectors::ContactPreference::Projection.new(
            phone_number: nil,
            email: nil,
            slack_id: nil,
            notification_user_id: SecureRandom.uuid,
            requested_preference: Contact::ContactPreference::IN_APP_NOTIFICATION
          )
        end

        let(:url) { "www.google.com" }

        it "fires off a create notification event and message sent event" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::NotificationCreated::V3,
              trace_id: message.trace_id,
              message_id: message.stream.message_id,
              data: {
                title: message.data.title,
                body: message.data.body,
                url: message.data.url,
                notification_id: be_a(String),
                user_id: projection.notification_user_id
              }
            ).and_call_original

          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::MessageSent::V1,
              trace_id: message.trace_id,
              message_id: message.stream.message_id,
              data: Core::Nothing
            ).and_call_original

          subject
        end
      end
    end
  end
end
