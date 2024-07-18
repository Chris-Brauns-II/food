class EducationExperiencesController < ApplicationController
  include Secured
  include SeekerAuth
  include MessageEmitter

  before_action :authorize
  before_action :set_seeker
  before_action :seeker_editor_authorize

  def create
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_education_experience(
        id: SecureRandom.uuid,
        person_id: params[:profile_id],
        trace_id: request.request_id,
        organization_name: education_experience_params[:organization_name],
        title: education_experience_params[:title],
        graduation_date: education_experience_params[:graduation_date],
        gpa: education_experience_params[:gpa],
        activities: education_experience_params[:activities]
      )

      head :created
    end
  end

  def update
    with_message_service do
      People::PersonEventEmitter.new(message_service:).add_education_experience(
        id: params[:id],
        person_id: params[:profile_id],
        trace_id: request.request_id,
        organization_name: education_experience_params[:organization_name],
        title: education_experience_params[:title],
        graduation_date: education_experience_params[:graduation_date],
        gpa: education_experience_params[:gpa],
        activities: education_experience_params[:activities]
      )

      head :accepted
    end
  end

  def destroy
    with_message_service do
      People::PersonEventEmitter.new(message_service:).remove_education_experience(
        trace_id: request.request_id,
        person_id: params[:profile_id],
        education_experience_id: params[:id]
      )

      head :accepted
    end
  end

  private

  attr_reader :seeker

  def set_seeker
    @seeker = Seeker.find(params[:profile_id])
  end

  def education_experience_params
    @education_experience_params ||= params.require(:education_experience).permit(
      :organization_name,
      :title,
      :graduation_date,
      :gpa,
      :activities
    ).to_h.symbolize_keys
  end
end
