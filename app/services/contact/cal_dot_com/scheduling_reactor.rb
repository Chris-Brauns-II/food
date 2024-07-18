module Contact
  module CalDotCom
    class SchedulingReactor < MessageReactor
      UnknownMeetingType = Class.new(StandardError)

      on_message Events::CalWebhookReceived::V1 do |message|
        return unless message.data.cal_trigger_event_type == Events::CalWebhookReceived::CalTriggerEventTypes::BOOKING_CREATED

        case message.data.payload[:type]
        when Events::CalWebhookReceived::KnownBookingTypes::CAREER_CONSULTATION
          handle_career_consolutation(message.trace_id, message.data.payload)
        else
          Sentry.capture_exception(UnknownMeetingType.new(message.data.payload[:type]))
        end
      end

      private

      def handle_career_consolutation(trace_id, payload)
        attendee = payload.dig(:attendees, 0)

        message_service.create!(
          trace_id:,
          person_id: SecureRandom.uuid,
          schema: Commands::AddPerson::V2,
          data: {
            user_id: nil,
            date_of_birth: nil,
            email: attendee[:email],
            phone_number: payload[:location],
            first_name: attendee[:firstName],
            last_name: attendee[:lastName],
            source_kind: People::SourceKind::THIRD_PARTY_INTEGRATION,
            source_identifier: "cal.com"
          }
        )
      end
    end
  end
end
