class RefreshTokenService
  def self.generate(user)
    raw_token = SecureRandom.hex(64)
    digest = Digest::SHA256.hexdigest(raw_token)

    user.refresh_tokens.create!(
      token_digest: digest,
      expires_at: 30.days.from_now
    )

    raw_token
  end

  def self.find(token)
    digest = Digest::SHA256.hexdigest(token)

    RefreshToken.active.find_by(token_digest: digest)
  end

  def self.revoke(token_record)
    token_record.update!(revoked_at: Time.current)
  end
end
