class Employers::JobsController < ApplicationController
  include Secured
  include EmployerAuth

  before_action :authorize
  before_action :employer_authorize

  def index
    employers = if current_user.employer_admin_role?
                  Employers::Employer.all
                else
                  [Employers::Recruiter.find_by!(email: current_user.email).employer]
                end

    employer_query = Employers::EmployerQuery.new(employers:)
    jobs = employer_query.all_jobs
    applicants = employer_query.all_applicants

    render json: { jobs:, applicants: }
  end
end
