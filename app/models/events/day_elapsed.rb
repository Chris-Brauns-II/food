module Events
  module DayElapsed
    module Data
      module DaysOfWeek
        ALL = [
          MONDAY = 'monday'.freeze,
          TUESDAY = 'tuesday'.freeze,
          WEDNESDAY = 'wednesday'.freeze,
          THURSDAY = 'thursday'.freeze,
          FRIDAY = 'friday'.freeze,
          SATURDAY = 'saturday'.freeze,
          SUNDAY = 'sunday'.freeze
        ].freeze
      end

      class V1
        extend Core::Payload

        schema do
          date Date, coerce: Core::DateCoercer
          day_of_week Either(*DaysOfWeek::ALL)
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Day,
      message_type: MessageTypes::DAY_ELAPSED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Date,
      message_type: MessageTypes::DAY_ELAPSED,
      version: 2
    )
  end
end
