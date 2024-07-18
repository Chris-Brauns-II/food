module Admin
  def admin_authorize
    unless current_user.admin_role?
      render json: { error: 'Not authorized' }, status: :unauthorized
      nil
    end
  end
end
