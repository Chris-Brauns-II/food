# frozen_string_literal: true

module Secured
  extend ActiveSupport::Concern

  attr_reader :current_user

  REQUIRES_AUTHENTICATION = { message: 'Requires authentication' }.freeze
  BAD_CREDENTIALS = {
    message: 'Bad credentials'
  }.freeze
  MALFORMED_AUTHORIZATION_HEADER = {
    error: 'invalid_request',
    error_description: 'Authorization header value must follow this format: Bearer access-token',
    message: 'Bad credentials'
  }.freeze

  def authorize(user_finder: UserFinder.new)
    set_current_user(user_finder:)

    render json: REQUIRES_AUTHENTICATION, status: :unauthorized unless current_user
  end

  def set_current_user(user_finder: UserFinder.new)
    token = token_from_request

    return unless token

    auth_client = AuthClient::Factory.build

    validation_response = auth_client.validate_token(token)

    if validation_response.success?
      @current_user = user_finder.find_or_create(
        sub: validation_response.sub,
        token:,
        auth_client:
      )
    end

    validation_response
  end

  private

  def token_from_request
    return request.headers['Authorization']&.split&.second if ENV['MOCK_AUTH'] == 'true'

    authorization_header_elements = request.headers['Authorization']&.split

    return unless authorization_header_elements
    return unless authorization_header_elements&.length == 2

    scheme, token = authorization_header_elements

    return unless scheme&.downcase == 'bearer'

    token
  end
end
