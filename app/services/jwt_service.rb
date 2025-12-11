# frozen_string_literal: true
class JwtService
  SECRET_KEY = Rails.application.secrets.secret_key_base
  ALGORITHM = 'HS256'

  def self.encode(payload, exp = 60.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.warn "JWT decode error: #{e.message}"
    nil
  end
end