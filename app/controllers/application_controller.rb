class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |e|
    Rails.logger.debug e
    render json: { error: 'Resource not found' }, status: :not_found
  end
end
