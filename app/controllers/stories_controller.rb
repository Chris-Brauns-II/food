class StoriesController < ApplicationController
  include Secured
  include SeekerAuth
  include MessageEmitter

  before_action :authorize
  before_action :set_seeker
  before_action :seeker_editor_authorize

  def create
    with_message_service do
      Seekers::StoriesService.new(seeker).create(
        **params.require(:story).permit(:prompt, :response).to_h.symbolize_keys
      )

      head :created
    end
  end

  def update
    story = Story.find(params[:id])

    with_message_service do
      Seekers::StoriesService.new(seeker).update(
        story:,
        **params.require(:story).permit(:prompt, :response).to_h.symbolize_keys
      )
    end

    head :accepted
  end

  def destroy
    story = Story.find(params[:id])

    with_message_service do
      Seekers::StoriesService.new(seeker).destroy(story:)
    end

    head :accepted
  end

  private

  attr_reader :seeker

  def set_seeker
    @seeker = Seeker.find(params[:profile_id])
  end
end
