module EmployerAuth
  def employer_authorize
    unless (@recruiter = current_user.recruiter || current_user.employer_admin_role?)
      render json: { error: 'Not authorized' }, status: :unauthorized
      nil
    end
  end

  private

  attr_reader :recruiter
end
