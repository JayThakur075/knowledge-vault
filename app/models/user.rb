class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :links, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
end
