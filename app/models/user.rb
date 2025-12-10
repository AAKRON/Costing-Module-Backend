# frozen_string_literal: true
class User < ApplicationRecord
  include Paginatable
  include Searchable

  has_secure_password
  enum role: [:user, :admin]
  
  validates :password, presence: true, length: { minimum: 8 }, if: :password_digest_changed?

  before_validation(on: :create) do
    generate_token
    set_default_role
  end

  def generate_token
    begin
      self.token = SecureRandom.hex
    end while self.class.exists?(token: token)
  end

  def full_name
    first_name || last_name ? first_name + ' ' + last_name : ''
  end

  def set_default_role
    self.role ||= :user
  end
end
