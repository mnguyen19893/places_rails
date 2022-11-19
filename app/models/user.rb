class User < ApplicationRecord
  has_secure_password

  has_many :created_places, foreign_key: 'user_id', class_name: 'Place'
  has_many :user_places
  has_many :places, through: :user_places
  has_many :device_infos

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, confirmation: true, on: :create

  def generate_password_token
    self.reset_password_token = SecureRandom.hex(4)
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid
    self.reset_password_sent_at + 4.hours > Time.now.utc
  end

  def reset_password(password)
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    self.password = password
    save!
  end
end
