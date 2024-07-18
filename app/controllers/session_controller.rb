class SessionController < ApplicationController
  include MessageEmitter
  include Secured

  before_action :authorize

  def create
    with_message_service do
      message_service.create!(
        schema: Events::SessionStarted::V1,
        user_id: current_user.id,
        data: Core::Nothing
      )

      head :accepted
    end
  end
end
