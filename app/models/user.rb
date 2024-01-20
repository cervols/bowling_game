# frozen_string_literal: true

class User < ApplicationRecord
  has_many :api_tokens

  validates :email, presence: true
  normalizes :email, with: -> email { email.strip.downcase }

  has_secure_password
end
