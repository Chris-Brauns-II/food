class OtherExperiencesController < ApplicationController
  include Secured
  include SeekerAuth
  include MessageEmitter

  before_action :authorize
  before_action :set_seeker
  before_action :seeker_editor_authorize

  def create
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_experience(
        id: SecureRandom.uuid,
        trace_id: request.request_id,
        person_id: params[:profile_id],
        organization_name: work_experience_params[:organization_name],
        position: work_experience_params[:position],
        start_date: work_experience_params[:start_date],
        end_date: work_experience_params[:end_date],
        is_current: work_experience_params[:is_current],
        description: work_experience_params[:description]
      )
    end

    head :created
  end

  def update
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_experience(
        id: params[:id],
        trace_id: request.request_id,
        person_id: params[:profile_id],
        organization_name: work_experience_params[:organization_name],
        position: work_experience_params[:position],
        start_date: work_experience_params[:start_date],
        end_date: work_experience_params[:end_date],
        is_current: work_experience_params[:is_current],
        description: work_experience_params[:description]
      )
    end

    head :accepted
  end

  def destroy
    with_message_service do
      People::PersonEventEmitter.new(message_service:).remove_experience(
        trace_id: request.request_id,
        experience_id: params[:id],
        person_id: params[:profile_id]
      )
    end

    head :accepted
  end

  private

  def work_experience_params
    @work_experience_params ||= params.require(:other_experience).permit(
      :organization_name,
      :position,
      :start_date,
      :end_date,
      :is_current,
      :description
    ).to_h.symbolize_keys
  end

  attr_reader :seeker

  def set_seeker
    @seeker = Seeker.find(params[:profile_id])
  end
end
