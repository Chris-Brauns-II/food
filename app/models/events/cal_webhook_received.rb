module Events
  module CalWebhookReceived
    module CalTriggerEventTypes
      ALL = [
        BOOKING_CREATED = 'BOOKING_CREATED'.freeze,
        BOOKING_RESCHEDULED = 'BOOKING_RESCHEDULED'.freeze,
        BOOKING_CANCELLED = 'BOOKING_CANCELLED'.freeze,
        MEETING_ENDED = 'MEETING_ENDED'.freeze,
        BOOKING_REJECTED = 'BOOKING_REJECTED'.freeze,
        BOOKING_REQUESTED = 'BOOKING_REQUESTED'.freeze,
        BOOKING_PAYMENT_INITIATED = 'BOOKING_PAYMENT_INITIATED'.freeze,
        BOOKING_PAID = 'BOOKING_PAID'.freeze,
        MEETING_STARTED = 'MEETING_STARTED'.freeze,
        RECORDING_READY = 'RECORDING_READY'.freeze,
        FORM_SUBMITTED = 'FORM_SUBMITTED'.freeze
      ].freeze
    end

    module KnownBookingTypes
      ALL = [
        CAREER_CONSULTATION = 'career-consultation'.freeze
      ].freeze
    end

    module Data
      class V1
        extend Core::Payload

        schema do
          cal_trigger_event_type Either(*CalTriggerEventTypes::ALL)
          payload Hash
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Integration,
      message_type: MessageTypes::Contact::CAL_WEBHOOK_RECEIVED,
      version: 1
    )
  end
end
