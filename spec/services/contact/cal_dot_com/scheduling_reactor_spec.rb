require 'rails_helper'

RSpec.describe Contact::CalDotCom::SchedulingReactor do
  it_behaves_like "a non replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new(message_service:).handle_message(message) }

    context "the event is a cal.com webhook recieved event" do
      let(:message) do
        build(
          :message,
          trace_id:,
          schema: Events::CalWebhookReceived::V1,
          data: {
            cal_trigger_event_type:,
            payload:
          }
        )
      end
      let(:message_service) { MessageService.new }
      let(:trace_id) { "78476f14-3e1a-4191-9f61-feed9a44951d" }
      let(:payload) { {} }

      context "when the trigger event is BOOKING_CREATED" do
        let(:cal_trigger_event_type) { Events::CalWebhookReceived::CalTriggerEventTypes::BOOKING_CREATED }

        context "when the payload type is CAREER_CONSULTATION" do
          let(:payload) do
            {
              type: Events::CalWebhookReceived::KnownBookingTypes::CAREER_CONSULTATION,
              attendees: [
                {
                  email: "john@skillarc.com",
                  firstName: "John",
                  lastName: "Chabot"
                }
              ],
              location: "+17403573931",
              organizer: {
                email: "katina@skillarc.com"
              }
            }
          end

          it "emits a add person command" do
            expect(message_service)
              .to receive(:create!)
              .with(
                trace_id:,
                person_id: be_a(String),
                schema: Commands::AddPerson::V2,
                data: {
                  user_id: nil,
                  date_of_birth: nil,
                  email: "john@skillarc.com",
                  phone_number: "+17403573931",
                  first_name: "John",
                  last_name: "Chabot",
                  source_kind: People::SourceKind::THIRD_PARTY_INTEGRATION,
                  source_identifier: "cal.com"
                }
              )
            subject
          end
        end

        context "when the payload type is anything else" do
          let(:payload) do
            { type: "some other meeting" }
          end

          it "does not emit a command and reports an error to sentry" do
            expect(message_service)
              .not_to receive(:create!)

            expect(Sentry)
              .to receive(:capture_exception)
              .with(be_a(described_class::UnknownMeetingType))

            subject
          end
        end
      end

      context "when the trigger event is anything else" do
        let(:cal_trigger_event_type) { Events::CalWebhookReceived::CalTriggerEventTypes::FORM_SUBMITTED }

        it "does nothing" do
          expect(message_service)
            .not_to receive(:create!)

          subject
        end
      end
    end
  end
end
