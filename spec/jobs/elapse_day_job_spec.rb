require 'rails_helper'

RSpec.describe ElapseDayJob do
  it "creates a day elapse event" do
    expect_any_instance_of(MessageService)
      .to receive(:create!)
      .with(
        date: "2020-01-01",
        schema: Events::DayElapsed::V2,
        data: {
          date: Date.new(2020, 1, 1),
          day_of_week: Events::DayElapsed::Data::DaysOfWeek::WEDNESDAY
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      ).and_call_original

    described_class.new.perform(Time.zone.local(2020, 1, 1))
  end
end
