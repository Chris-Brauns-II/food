module Employers
  class ChatsController < ApplicationController
    include Secured
    include EmployerAuth
    include MessageEmitter

    before_action :authorize
    before_action :employer_authorize
    before_action :set_recruiter

    def index
      with_message_service do
        render json: EmployerChats.new(recruiter:, message_service:).get
      end
    end

    def mark_read
      with_message_service do
        EmployerChats.new(recruiter:, message_service:).mark_read(
          application_id: params[:applicant_id]
        )
      end

      head :accepted
    end

    def send_message
      with_message_service do
        EmployerChats.new(recruiter:, message_service:).send_message(
          application_id: params[:applicant_id],
          message: params[:message]
        )
      end

      head :accepted
    end

    def create
      applicant = Employers::Applicant.find_by!(applicant_id: params[:applicant_id])
      job = applicant.job

      with_message_service do
        EmployerChats.new(recruiter:, message_service:).create(
          application_id: params[:applicant_id],
          job_id: job.job_id,
          seeker_id: applicant.seeker_id,
          title: "#{applicant.first_name} #{applicant.last_name} - #{job.employment_title}"
        )
      end

      head :created
    end

    private

    attr_reader :recruiter

    def set_recruiter
      @recruiter = if current_user.employer_admin_role?
                     EmployerChats::Recruiter.new(current_user, ::Employer.pluck(:id))
                   else
                     EmployerChats::Recruiter.new(recruiter.user, recruiter.employer_id)
                   end
    end
  end
end
