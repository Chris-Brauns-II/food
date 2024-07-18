module Contact
  module Projectors
    class ContactPreference < Projector
      projection_stream Streams::Person

      class Projection
        NoValidOption = Class.new(StandardError)

        extend Record

        schema do
          phone_number Either(String, nil)
          email Either(String, nil)
          slack_id Either(String, nil)
          notification_user_id Either(String, nil)
          requested_preference Either(*Contact::ContactPreference::ALL)
        end

        def preference
          case requested_preference
          when Contact::ContactPreference::NONE
            default_preference
          when Contact::ContactPreference::EMAIL
            pick_preference(email.present?, Contact::ContactPreference::EMAIL)
          when Contact::ContactPreference::SMS
            pick_preference(phone_number.present?, Contact::ContactPreference::SMS)
          when Contact::ContactPreference::IN_APP_NOTIFICATION
            pick_preference(notification_user_id.present?, Contact::ContactPreference::IN_APP_NOTIFICATION)
          when Contact::ContactPreference::SLACK
            pick_preference(slack_id.present?, Contact::ContactPreference::SLACK)
          end
        end

        private

        def pick_preference(condition, preference)
          if condition
            preference
          else
            default_preference
          end
        end

        def default_preference
          return Contact::ContactPreference::SLACK if slack_id.present?
          return Contact::ContactPreference::SMS if phone_number.present?
          return Contact::ContactPreference::EMAIL if email.present?
          return Contact::ContactPreference::IN_APP_NOTIFICATION if notification_user_id.present?

          # This should never happen but just in case
          raise NoValidOption
        end
      end

      def init
        Projection.new(
          phone_number: nil,
          email: nil,
          slack_id: nil,
          notification_user_id: nil,
          requested_preference: Contact::ContactPreference::NONE
        )
      end

      on_message Events::PersonAdded::V1 do |message, accumulator|
        accumulator = accumulator.with(phone_number: message.data.phone_number) if message.data.phone_number.present?
        accumulator = accumulator.with(email: message.data.email) if message.data.email.present?
        accumulator
      end

      on_message Events::BasicInfoAdded::V1 do |message, accumulator|
        accumulator = accumulator.with(phone_number: message.data.phone_number) if message.data.phone_number.present?
        accumulator = accumulator.with(email: message.data.email) if message.data.email.present?
        accumulator
      end

      on_message Events::SlackIdAdded::V2 do |message, accumulator|
        accumulator.with(slack_id: message.data.slack_id)
      end

      on_message Events::PersonAssociatedToUser::V1 do |message, accumulator|
        accumulator.with(notification_user_id: message.data.user_id)
      end

      on_message Events::ContactPreferenceSet::V2 do |message, accumulator|
        accumulator.with(requested_preference: message.data.preference)
      end
    end
  end
end
