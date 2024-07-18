module Slack
  class SlackReactor < MessageReactor
    def initialize(client: Slack::Gateway.build, **params)
      super(**params)
      @client = client
    end

    on_message Commands::SendSlackMessage::V2 do |message|
      client.chat_postMessage(
        channel: message.data.channel,
        text: message.data.text,
        blocks: message.data.blocks,
        as_user: true
      )

      message_service.create_once_for_stream!(
        schema: ::Events::SlackMessageSent::V2,
        trace_id: message.trace_id,
        message_id: message.stream.message_id,
        data: message.data.to_h
      )
    end

    on_message ::Events::ApplicantStatusUpdated::V6 do |message|
      data = message.data
      return unless data.status == ApplicantStatus::StatusTypes::NEW

      client.chat_postMessage(
        channel: '#feed',
        text: "<#{ENV.fetch('FRONTEND_URL', nil)}/profiles/#{data.seeker_id}|#{data.applicant_email}> has applied to *#{data.employment_title}* at *#{data.employer_name}*",
        as_user: true
      )
    end

    on_message ::Events::ChatMessageSent::V2 do |message|
      applicant_status_updated = Projectors::Streams::GetFirst.project(
        stream: Streams::Application.new(application_id: message.stream.id),
        schema: ::Events::ApplicantStatusUpdated::V6
      )

      return if applicant_status_updated.blank?

      data = applicant_status_updated.data

      message = if data.user_id == message.data.from_user_id
                  "Applicant <#{ENV.fetch('FRONTEND_URL', nil)}/profiles/#{data.seeker_id}|#{data.applicant_email}> has *sent* a message to *#{data.employer_name}* for their applcation to *#{data.employment_title}*."
                else
                  "Applicant <#{ENV.fetch('FRONTEND_URL', nil)}/profiles/#{data.seeker_id}|#{data.applicant_email}> has *received* a message from *#{data.employer_name}* for their applcation to *#{data.employment_title}*."
                end

      client.chat_postMessage(
        channel: '#feed',
        text: message,
        as_user: true
      )
    end

    on_message ::Events::UserCreated::V1 do |message|
      client.chat_postMessage(
        channel: '#feed',
        text: "New user signed up: *#{message.data.email}*",
        as_user: true
      )
    end

    private

    attr_reader :client
  end
end
