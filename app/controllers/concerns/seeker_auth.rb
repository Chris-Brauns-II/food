module SeekerAuth
  include CoachAuth

  def seeker_editor_authorize
    return if seeker_editor?

    render json: { error: 'Not authorized' }, status: :unauthorized
    nil
  end

  def seeker_editor?
    return false unless current_user
    return false unless seeker

    seeker.user_id == current_user.id || coach?
  end
end
