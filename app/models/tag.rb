class Tag < ApplicationRecord
  belongs_to :user, touch: true
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags
  has_many :link_tags, dependent: :destroy
  has_many :links, through: :link_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }

  normalizes :name, with: ->(name) { name.strip.downcase }
end
