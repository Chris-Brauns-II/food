module JobOrders
  class TeamOrderStatusReactor < MessageReactor
    def can_replay?
      false
    end

    on_message ::Events::DayElapsed::V2 do |message|
      # Don't bother on the weekened
      return if message.data.day_of_week == ::Events::DayElapsed::Data::DaysOfWeek::SATURDAY
      return if message.data.day_of_week == ::Events::DayElapsed::Data::DaysOfWeek::SUNDAY

      # Determine who owns which order status
      team_status_owners = OrderStatus::ALL.each_with_object({}) do |order_status, owners|
        owner = ::Projectors::Streams::GetLast.project(
          stream: Streams::OrderStatus.new(order_status:),
          schema: Events::TeamResponsibleForStatus::V1
        )

        next if owner.nil?

        owners[order_status] = owner.data.team_id
      end

      return if team_status_owners.empty?

      # Grab each job order following into an owned status
      # grab some meta data for a message
      team_job_owners = {}

      JobOrder.for_applicable_jobs.find_each do |job_order|
        team_owner_id = team_status_owners[job_order.status]
        next if team_owner_id.nil?

        team_job_owners[team_owner_id] ||= []
        team_job_owners[team_owner_id] << {
          id: job_order.id,
          status: job_order.status,
          employer_name: job_order.job.employer_name,
          employment_title: job_order.job.employment_title,
          opened_at: job_order.opened_at
        }
      end

      team_job_owners.each do |team_id, job_orders|
        message_service.create!(
          trace_id: message.trace_id,
          task_id: SecureRandom.uuid,
          schema: ::Commands::ScheduleTask::V1,
          data: {
            # At some point we're going to want this time picking to
            # be more rebust
            execute_at: message.data.date.in_time_zone("Eastern Time (US & Canada)") + 8.hours,
            command: message_service.build(
              trace_id: message.trace_id,
              team_id:,
              schema: Teams::Commands::SendSlackMessage::V2,
              data: {
                blocks: slack_message_blocks(job_orders)
              }
            )
          },
          metadata: {
            requestor_type: Requestor::Kinds::SERVER,
            requestor_id: nil
          }
        )
      end
    end

    private

    def slack_message_blocks(job_orders)
      [
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
              elements: job_orders.sort_by { |order| order[:opened_at] }.map { |job_order| list_item(job_order) }
            }
          ]
        }
      ]
    end

    def list_item(job_order)
      {
        type: "rich_text_section",
        elements: [
          {
            type: "text",
            text: "#{job_order[:employer_name]} - "
          },
          {
            type: "link",
            url: "#{ENV.fetch('FRONTEND_URL', nil)}/orders/#{job_order[:id]}",
            text: job_order[:employment_title],
            style: {
              bold: true
            }
          },
          {
            type: "text",
            text: ": #{job_order[:status]}",
            style: {
              bold: true
            }
          }
        ]
      }
    end
  end
end
