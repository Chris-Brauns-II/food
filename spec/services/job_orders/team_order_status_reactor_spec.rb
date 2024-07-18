require 'rails_helper'

RSpec.describe JobOrders::TeamOrderStatusReactor do
  it_behaves_like "a non replayable message consumer"

  before do
    messages.each do |message|
      Event.from_message!(message)
    end
  end

  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:messages) { [] }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message day elapsed" do
      let(:message) do
        build(
          :message,
          stream_id: date,
          schema: Events::DayElapsed::V2,
          data: {
            day_of_week:,
            date:
          }
        )
      end

      let(:date) { Date.today } # rubocop:disable Rails/Date
      let(:team_id) { SecureRandom.uuid }

      context "when the day of the week indicates the weekend" do
        let(:message_service) { double }
        let(:day_of_week) { Events::DayElapsed::Data::DaysOfWeek::SATURDAY }

        it "does nothing" do
          subject
        end
      end

      context "when the day of the week indicates a weekday" do
        let(:day_of_week) { Events::DayElapsed::Data::DaysOfWeek::WEDNESDAY }

        context "when no team has been assigned to a status" do
          let(:message_service) { double }

          it "does nothing" do
            subject
          end
        end

        context "when a team has been assigned to a status" do
          let(:messages) do
            [
              build(
                :message,
                stream_id: JobOrders::ActivatedStatus::OPEN,
                schema: JobOrders::Events::TeamResponsibleForStatus::V1,
                data: {
                  team_id:
                }
              )
            ]
          end

          context "when no job order has the assigned status" do
            let!(:job_order) { create(:job_orders__job_order, status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER) }

            let(:message_service) { double }

            it "does nothing" do
              subject
            end
          end

          context "when job orders have the assigned status" do
            let(:id1) { SecureRandom.uuid }
            let(:id2) { SecureRandom.uuid }

            let!(:job_order1) { create(:job_orders__job_order, id: id1, job: job1, opened_at: date - 2.days, status: JobOrders::ActivatedStatus::OPEN) }
            let!(:job_order2) { create(:job_orders__job_order, id: id2, job: job2, opened_at: date - 1.day, status: JobOrders::ActivatedStatus::OPEN) }

            let(:job1) { create(:job_orders__job, employment_title: "1", employer_name: "A") }
            let(:job2) { create(:job_orders__job, employment_title: "2", employer_name: "B") }
            let(:base_url) { ENV.fetch('FRONTEND_URL', nil) }

            it "emits a schedule task command with a team message embedded" do
              allow(message_service)
                .to receive(:build)
                .and_call_original

              expect(message_service)
                .to receive(:build)
                .with(
                  trace_id: message.trace_id,
                  team_id:,
                  schema: Teams::Commands::SendSlackMessage::V2,
                  data: {
                    blocks: [
                      {
                        type: "header",
                        text: {
                          type: "plain_text",
                          text: "Good morning team! :smile:",
                          emoji: true
                        }
                      },
                      {
                        type: "rich_text",
                        elements: [
                          {
                            type: "rich_text_section",
                            elements: [
                              {
                                type: "text",
                                text: "The following job orders are active an assigned here. Please provide any relevant updates on each order.\n"
                              }
                            ]
                          },
                          {
                            type: "rich_text_list",
                            style: "bullet",
                            indent: 0,
                            border: 0,
                            elements: [
                              {
                                type: "rich_text_section",
                                elements: [
                                  {
                                    type: "text",
                                    text: "A - "
                                  },
                                  {
                                    type: "link",
                                    url: "#{base_url}/orders/#{id1}",
                                    text: "1",
                                    style: {
                                      bold: true
                                    }
                                  },
                                  {
                                    type: "text",
                                    text: ": open",
                                    style: {
                                      bold: true
                                    }
                                  }
                                ]
                              },
                              {
                                type: "rich_text_section",
                                elements: [
                                  {
                                    type: "text",
                                    text: "B - "
                                  },
                                  {
                                    type: "link",
                                    url: "#{base_url}/orders/#{id2}",
                                    text: "2",
                                    style: {
                                      bold: true
                                    }
                                  },
                                  {
                                    type: "text",
                                    text: ": open",
                                    style: {
                                      bold: true
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ).and_call_original

              expect(message_service)
                .to receive(:create!)
                .with(
                  trace_id: message.trace_id,
                  task_id: be_a(String),
                  schema: Commands::ScheduleTask::V1,
                  data: {
                    # At some point we're going to want this time picking to
                    # be more rebust
                    execute_at: date.in_time_zone("Eastern Time (US & Canada)") + 8.hours,
                    command: be_a(Message)
                  },
                  metadata: {
                    requestor_type: Requestor::Kinds::SERVER,
                    requestor_id: nil
                  }
                ).and_call_original

              subject
            end
          end
        end
      end
    end
  end
end
