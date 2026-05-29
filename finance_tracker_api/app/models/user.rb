# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :transactions, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def generate_jwt
    JwtService.encode({ user_id: id })
  end
end
