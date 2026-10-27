class Note < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  validates :title, presence: true
  validates :note_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :favorites, -> { where(favorite: true) }
end
