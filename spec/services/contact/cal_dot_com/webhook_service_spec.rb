require 'rails_helper'

RSpec.describe Contact::CalDotCom::WebhookService do
  describe ".handle_webhook" do
    subject { described_class.handle_webhook(webhook) }

    include_context "event emitter"

    let(:webhook_string) { '{"triggerEvent":"BOOKING_CREATED","createdAt":"2024-03-13T17:33:05.126Z","payload":{"bookerUrl":"https://cal.com","type":"15min","title":"15 Min Meeting between John Chabot and John Chabot","description":"Bro","additionalNotes":"Bro","customInputs":{},"startTime":"2024-03-14T14:00:00Z","endTime":"2024-03-14T14:15:00Z","organizer":{"id":692405,"name":"John Chabot","email":"john@skillarc.com","username":"skillarc","timeZone":"America/New_York","language":{"locale":"en"},"timeFormat":"h:mma","utcOffset":-240},"responses":{"name":{"label":"your_name","value":"John Chabot"},"email":{"label":"email_address","value":"john@skillarc.com"},"location":{"label":"location","value":{"optionValue":"+17403573931","value":"phone"}},"title":{"label":"what_is_this_meeting_about"},"notes":{"label":"additional_notes","value":"Bro"},"guests":{"label":"additional_guests","value":[]},"rescheduleReason":{"label":"reason_for_reschedule"}},"userFieldsResponses":{"title":{"label":"what_is_this_meeting_about"}},"attendees":[{"email":"john@skillarc.com","name":"John Chabot","firstName":"","lastName":"","timeZone":"America/New_York","language":{"locale":"en"},"utcOffset":-240}],"location":"+17403573931","destinationCalendar":[{"id":216470,"integration":"google_calendar","externalId":"john@skillarc.com","primaryEmail":"john@skillarc.com","userId":692405,"eventTypeId":null,"credentialId":331160}],"hideCalendarNotes":false,"requiresConfirmation":false,"eventTypeId":678132,"seatsShowAttendees":true,"seatsPerTimeSlot":null,"seatsShowAvailabilityCount":true,"schedulingType":null,"iCalUID":"ua2wm7UKatt1mjufZJxoXu@Cal.com","iCalSequence":0,"uid":"ua2wm7UKatt1mjufZJxoXu","appsStatus":[{"appName":"google-calendar","type":"google_calendar","success":1,"failures":0,"errors":[],"warnings":[]}],"eventTitle":"15 Min Meeting","eventDescription":"","price":0,"currency":"usd","length":15,"bookingId":1516720,"metadata":{},"status":"ACCEPTED"}}' }
    let(:webhook) { JSON.parse(webhook_string) }

    it "creates a Webhook record" do
      expect_any_instance_of(MessageService)
        .to receive(:create!)
        .with(
          schema: Events::CalWebhookReceived::V1,
          integration: "cal.com",
          data: {
            cal_trigger_event_type: webhook["triggerEvent"],
            payload: webhook["payload"].deep_symbolize_keys
          },
          occurred_at: webhook["createdAt"]
        )
        .and_call_original

      subject
    end
  end
end
