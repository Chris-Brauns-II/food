module CoachAuth
  def coach_authorize
    return if coach?

    render json: { error: 'Not authorized' }, status: :unauthorized
    nil
  end

  def coach?
    return false unless current_user

    current_user.coach_role?
  end
end
