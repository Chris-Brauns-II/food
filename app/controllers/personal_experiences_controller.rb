class PersonalExperiencesController < ApplicationController
  include Secured
  include MessageEmitter

  before_action :authorize

  def create
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_personal_experience(
        id: SecureRandom.uuid,
        trace_id: request.request_id,
        person_id: current_user.seeker.id,
        activity: personal_experience_params[:activity],
        start_date: personal_experience_params[:start_date],
        end_date: personal_experience_params[:end_date],
        description: personal_experience_params[:description]
      )
    end

    head :created
  end

  def update
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_personal_experience(
        id: params[:id],
        trace_id: request.request_id,
        person_id: current_user.seeker.id,
        activity: personal_experience_params[:activity],
        start_date: personal_experience_params[:start_date],
        end_date: personal_experience_params[:end_date],
        description: personal_experience_params[:description]
      )
    end

    head :accepted
  end

  def destroy
    with_message_service do
      People::PersonEventEmitter.new(message_service:).remove_personal_experience(
        person_id: current_user.seeker.id,
        trace_id: request.request_id,
        personal_experience_id: params[:id]
      )
    end

    head :accepted
  end

  private

  attr_reader :seeker

  def set_seeker
    @seeker = Seeker.find(params[:profile_id])
  end

  def personal_experience_params
    @personal_experience_params ||= params.require(:personal_experience).permit(
      :activity, :start_date, :end_date, :description
    ).to_h.symbolize_keys
  end
end
