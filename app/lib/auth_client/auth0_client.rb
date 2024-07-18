# frozen_string_literal: true

require 'jwt'
require 'net/http'

module AuthClient
  class Auth0Client
    def initialize(auth0_domain:)
      @auth0_domain = auth0_domain
    end

    # Token Validation
    def validate_token(token)
      result = jwks_hash
      return result if result.is_a?(ValidationResponse)

      decoded_token = decode_token(token, result)

      _, sub = decoded_token[0]['sub'].split('|')

      ValidationResponse.ok(sub:)
    rescue JWT::VerificationError, JWT::DecodeError => _e
      ValidationResponse.err(message: 'Bad credentials', status: :unauthorized)
    end

    def get_user_info(token)
      uri = URI("https://#{@auth0_domain}/userinfo")
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Bearer #{token}"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end

    private

    def decode_token(token, jwks_hash)
      JWT.decode(token, nil, true, {
                   algorithm: 'RS256',
                   iss: "https://#{@auth0_domain}/",
                   verify_iss: true,
                   aud: 'https://hello-world.example.com',
                   verify_aud: true,
                   jwks: { keys: jwks_hash[:keys] }
                 })
    end

    def jwks_hash
      return @jwks_hash if @jwks_hash

      jwks_response = jwks

      return ValidationResponse.err(message: 'Unable to verify credentials', status: :internal_server_error) unless jwks_response.is_a? Net::HTTPSuccess

      @jwks_hash = JSON.parse(jwks_response.body).deep_symbolize_keys
    end

    def jwks
      jwks_uri = URI("https://#{@auth0_domain}/.well-known/jwks.json")

      Net::HTTP.get_response jwks_uri
    end
  end
end
