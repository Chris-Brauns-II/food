require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Contact::CalDotCom::WebhooksController", type: :request do
  path '/contact/cal_dot_com/webhooks' do
    post "Consume webhook" do
      tags 'Contact'
      consumes 'application/json'
      parameter name: 'X-Cal-Signature-256',
                in: :header,
                schema: {
                  type: :string
                }
      parameter name: :webhook,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    triggerEvent: {
                      type: :string
                    },
                    createdAt: {
                      type: :string,
                      format: :datetime
                    },
                    payload: {
                      type: :object
                    }
                  }
                }

      let(:webhook) do
        { "triggerEvent" => "BOOKING_CREATED",
          "createdAt" => "2024-03-13T17:33:05.126Z",
          "payload" =>
         { "bookerUrl" => "https://cal.com",
           "type" => "15min",
           "title" => "15 Min Meeting between John Chabot and John Chabot",
           "description" => "Bro",
           "additionalNotes" => "Bro",
           "customInputs" => {},
           "startTime" => "2024-03-14T14:00:00Z",
           "endTime" => "2024-03-14T14:15:00Z",
           "organizer" =>
           { "id" => 692_405, "name" => "John Chabot", "email" => "john@skillarc.com", "username" => "skillarc", "timeZone" => "America/New_York", "language" => { "locale" => "en" }, "timeFormat" => "h:mma", "utcOffset" => -240 },
           "responses" =>
           { "name" => { "label" => "your_name", "value" => "John Chabot" },
             "email" => { "label" => "email_address", "value" => "john@skillarc.com" },
             "location" => { "label" => "location", "value" => { "optionValue" => "+17403573931", "value" => "phone" } },
             "title" => { "label" => "what_is_this_meeting_about" },
             "notes" => { "label" => "additional_notes", "value" => "Bro" },
             "guests" => { "label" => "additional_guests", "value" => [] },
             "rescheduleReason" => { "label" => "reason_for_reschedule" } },
           "userFieldsResponses" => { "title" => { "label" => "what_is_this_meeting_about" } },
           "attendees" => [{ "email" => "john@skillarc.com", "name" => "John Chabot", "firstName" => "", "lastName" => "", "timeZone" => "America/New_York", "language" => { "locale" => "en" }, "utcOffset" => -240 }],
           "location" => "+17403573931",
           "destinationCalendar" =>
           [{ "id" => 216_470, "integration" => "google_calendar", "externalId" => "john@skillarc.com", "primaryEmail" => "john@skillarc.com", "userId" => 692_405, "eventTypeId" => nil, "credentialId" => 331_160 }],
           "hideCalendarNotes" => false,
           "requiresConfirmation" => false,
           "eventTypeId" => 678_132,
           "seatsShowAttendees" => true,
           "seatsPerTimeSlot" => nil,
           "seatsShowAvailabilityCount" => true,
           "schedulingType" => nil,
           "iCalUID" => "ua2wm7UKatt1mjufZJxoXu@Cal.com",
           "iCalSequence" => 0,
           "uid" => "ua2wm7UKatt1mjufZJxoXu",
           "appsStatus" => [{ "appName" => "google-calendar", "type" => "google_calendar", "success" => 1, "failures" => 0, "errors" => [], "warnings" => [] }],
           "eventTitle" => "15 Min Meeting",
           "eventDescription" => "",
           "price" => 0,
           "currency" => "usd",
           "length" => 15,
           "bookingId" => 1_516_720,
           "metadata" => {},
           "status" => "ACCEPTED" } }
      end

      response "403", 'Forbidden' do
        context "when the payload cal signature doesn't match the payload and key" do
          before do
            expect(Contact::CalDotCom::WebhookService)
              .not_to receive(:handle_webhook)
          end

          let(:'X-Cal-Signature-256') { 'not expected' }

          run_test!
        end
      end

      response "202", "Accepted" do
        context "when the payload cal signature doesn't match the payload and key" do
          before do
            expect(Contact::CalDotCom::WebhookService)
              .to receive(:handle_webhook)
              .and_call_original
          end

          let(:'X-Cal-Signature-256') { '1a78da8279d1bc22bd72ff9f3816b1ac1731d198daa52b067ff6f7b69732b360' }

          run_test!
        end
      end
    end
  end
end
