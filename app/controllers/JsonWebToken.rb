require 'jwt'

class JsonWebToken
  # SECRET_KEY is the key for encoding and decoding tokens.
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  # payload: is a key-value object for holding data that they want to be encoded.
  # exp: stand for expiration for holding expiration time token.
  #      If exp is not specified, it will give you the default value in 24 hours or one day.
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # We decoded the token given by the user and get the first value then assign it to a decoded variable
  # The first value contains a payload that we already encoded before and the second value contain information
  # about the algorithm that we use for encoding and decoding token
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end
