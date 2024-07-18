module AuthClient
  class Factory
    def self.build(auth0_domain: ENV.fetch('AUTH0_DOMAIN', nil), mock_auth: ENV.fetch('MOCK_AUTH', nil), mock_email: ENV.fetch('MOCK_USER_EMAIL', nil), mock_sub: ENV.fetch('MOCK_USER_SUB', nil))
      if mock_auth == 'true'
        AuthClient::Fake.new(
          email: mock_email,
          sub: mock_sub
        )
      else
        AuthClient::Auth0Client.new(
          auth0_domain:
        )
      end
    end
  end
end
