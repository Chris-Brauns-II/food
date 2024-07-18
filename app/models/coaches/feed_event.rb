# == Schema Information
#
# Table name: coaches_feed_events
#
#  id           :uuid             not null, primary key
#  description  :text             not null
#  occurred_at  :datetime         not null
#  seeker_email :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  context_id   :string           not null
#
module Coaches
  class FeedEvent < ApplicationRecord
  end
end
