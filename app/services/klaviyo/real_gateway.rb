module Klaviyo
  class RealGateway
    ClientSideEventError = Class.new(StandardError)
    ServerSideEventError = Class.new(StandardError)

    def initialize(api_key:)
      @api_key = api_key
    end

    def application_status_updated(application_id:, email:, event_id:, employment_title:, employer_name:, occurred_at:, status:) # rubocop:disable Metrics/ParameterLists
      data = event_data(
        event_type: 'Application Status Updated',
        email:,
        time: occurred_at,
        event_id:,
        event_properties: {
          application_id:,
          employment_title:,
          employer_name:,
          status:
        }
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def chat_message_received(email:, event_id:, occurred_at:, applicant_id:, employment_title:, employer_name:) # rubocop:disable Metrics/ParameterLists
      data = event_data(
        event_type: 'Chat Message Received',
        email:,
        time: occurred_at,
        event_id:,
        event_properties: {
          applicant_id:,
          employer_name:,
          employment_title:
        }
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def person_added(email:, occurred_at:, event_id:, profile_attributes:, profile_properties:)
      data = event_data(
        event_type: 'Person Added',
        email:,
        time: occurred_at,
        event_id:,
        profile_properties:,
        profile_attributes:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def job_saved(email:, event_id:, event_properties:, occurred_at:)
      data = event_data(
        event_type: 'Job Saved',
        email:,
        time: occurred_at,
        event_id:,
        event_properties:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def lead_captured(email:, occurred_at:, event_id:, profile_attributes:)
      data = event_data(
        event_type: 'Lead Capture',
        email:,
        profile_attributes:,
        time: occurred_at, event_id:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def user_signup(email:, occurred_at:, event_id:)
      data = event_data(event_type: 'User Signup', email:, time: occurred_at, event_id:)

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def user_updated(email:, occurred_at:, event_id:, profile_properties:, profile_attributes:)
      data = event_data(
        event_type: 'User Updated',
        email:,
        time: occurred_at,
        event_id:,
        profile_properties:,
        profile_attributes:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def education_experience_entered(email:, occurred_at:, event_id:)
      data = event_data(event_type: 'Education Experience Entered', email:, time: occurred_at, event_id:)

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def employer_invite_accepted(email:, occurred_at:, event_id:, profile_properties:)
      data = event_data(
        event_type: 'Employer Invite Accepted',
        email:,
        time: occurred_at,
        event_id:,
        profile_properties:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def training_provider_invite_accepted(email:, occurred_at:, event_id:, profile_properties:)
      data = event_data(
        event_type: 'Training Provider Invite Accepted',
        email:,
        time: occurred_at,
        event_id:,
        profile_properties:
      )

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def experience_entered(email:, occurred_at:, event_id:)
      data = event_data(event_type: 'Experience Entered', email:, time: occurred_at, event_id:)

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    def onboarding_complete(email:, occurred_at:, event_id:)
      data = event_data(event_type: 'Onboarding Complete', email:, time: occurred_at, event_id:)

      url = URI("https://a.klaviyo.com/api/events/")

      post(url, data)
    end

    private

    attr_reader :api_key

    def event_data(event_type:, email:, time:, event_id:, event_properties: {}, profile_properties: {}, profile_attributes: {}) # rubocop:disable Metrics/ParameterLists
      {
        data: {
          type: "event",
          attributes: {
            properties: {
              **event_properties
            },
            metric: {
              data: {
                type: "metric",
                attributes: {
                  name: event_type
                }
              }
            },
            profile: {
              data: {
                type: "profile",
                attributes: {
                  **profile_attributes,
                  email:,
                  properties: {
                    **profile_properties
                  }
                }
              }
            },
            time: time.strftime("%Y-%m-%dT%H:%M"),
            unique_id: event_id
          }
        }
      }
    end

    def post(url, data)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["accept"] = 'application/json'
      request["revision"] = '2023-10-15'
      request["content-type"] = 'application/json'
      request["Authorization"] = "Klaviyo-API-Key #{api_key}"

      request.body = data.to_json

      response = http.request(request)

      case response.code
      when /4../
        Sentry.capture_exception(ClientSideEventError.new(response.body["errors"]))
        # response.body["errors"].each do |error|
        #   Sentry.capture_exception(ClientSideEventError.new(error_message(response.code, error)))
        # end
      when /5../
        Sentry.capture_exception(ServerSideEventError.new(response.body["errors"]))
        # response.body["errors"].each do |error|
        #   Sentry.capture_exception(ServerSideEventError.new(error_message(response.code, error)))
        # end
      end

      Rails.logger.info("Klaviyo response: #{response.body}")
    end

    def error_message(response_code, error)
      "Status code #{response_code}. Klavyio code #{error['code']}. #{error['title']} #{error['details']}"
    end
  end
end
