class Category < ApplicationRecord
  belongs_to :user, touch: true

  has_many :notes, dependent: :nullify
  has_many :links, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
end
