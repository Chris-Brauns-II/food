module Seekers
  class JobsController < ApplicationController
    include MessageEmitter
    include Secured

    before_action :set_current_user, only: [:index]
    before_action :authorize, only: %i[save unsave]

    def index
      with_message_service do
        render json: JobSearch::JobSearchQuery.new(message_service:).search(
          search_terms: params[:search_terms] || params[:utm_term],
          industries: params[:industries],
          tags: params[:tags],
          user: current_user,
          utm_source: params[:utm_source]
        )
      end
    end

    def save
      with_message_service do
        message_service.create!(
          schema: Events::JobSaved::V1,
          user_id: current_user.id,
          data: {
            job_id: job.id,
            employment_title: job.employment_title,
            employer_name: job.employer.name
          }
        )
      end

      head :accepted
    end

    def unsave
      with_message_service do
        message_service.create!(
          schema: Events::JobUnsaved::V1,
          user_id: current_user.id,
          data: {
            job_id: job.id,
            employment_title: job.employment_title,
            employer_name: job.employer.name
          }
        )
      end

      head :accepted
    end

    private

    def job
      @job ||= Job.find(params[:job_id])
    end
  end
end
