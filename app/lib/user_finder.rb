class UserFinder
  include MessageEmitter

  def find_or_create(sub:, token:, auth_client:)
    u = User.find_by(sub:)

    return u if u

    info = auth_client.get_user_info(token)

    begin
      new_user = User.create!(
        id: SecureRandom.uuid,
        email: info['email'],
        email_verified: info['email_verified'],
        image: info['picture'],
        sub:
      )

      with_message_service do
        message_service.create!(
          user_id: new_user.id,
          schema: Events::UserCreated::V1,
          data: {
            first_name: new_user.first_name,
            last_name: new_user.last_name,
            email: new_user.email,
            sub: new_user.sub
          },
          occurred_at: new_user.created_at
        )
      end

      new_user
    rescue ActiveRecord::RecordNotUnique
      # We had a race condition and a user was created
      # after the find occurred
      User.find_by!(sub:)
    end
  end
end
