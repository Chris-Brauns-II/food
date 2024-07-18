# frozen_string_literal: true

module Teams
  module MessageTypes
    EVENTS = [
      ADDED = "team_added",
      ADD_USER_TO_TEAM = "add_user_to_team",
      REMOVE_USER_FROM_TEAM = "remove_user_from_team",
      PRIMARY_SLACK_CHANNEL_ADDED = "team_primary_slack_channel_added",
      SEND_SLACK_MESSAGE = "send_team_slack_message"
    ].freeze

    COMMANDS = [
      ADD = "add_team",
      USER_ADDED_TO_TEAM = "user_added_to_team",
      USER_REMOVED_FROM_TEAM = "user_removed_from_team",
      ADD_PRIMAY_SLACK_CHANNEL = "add_team_primary_slack_channel"
    ].freeze
  end
end
