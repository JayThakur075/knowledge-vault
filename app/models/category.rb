class Category < ApplicationRecord
  belongs_to :user

  has_many :notes, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
end
