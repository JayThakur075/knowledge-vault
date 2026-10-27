class Note < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  validates :title, presence: true
  validates :note_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :favorites, -> { where(favorite: true) }
end
