class Note < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :category, optional: true

  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  validates :title, presence: true
  validates :note_type, presence: true
  validate :category_belongs_to_user

  scope :recent, -> { order(created_at: :desc) }
  scope :favorites, -> { where(favorite: true) }

  def self.search_and_filter(user, filters)
    notes = user.notes.includes(:category, :tags).recent
    if filters[:query].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(filters[:query])}%"
      notes = notes.left_joins(:tags).where(
        "notes.title LIKE :term OR notes.content LIKE :term OR tags.name LIKE :term", term: term
      )
    end
    notes = notes.where(note_type: filters[:note_type]) if filters[:note_type].present?
    notes = notes.where(favorite: true) if filters[:favorite] == "true"
    notes = notes.where(category_id: user.categories.select(:id).where(id: filters[:category_id])) if filters[:category_id].present?
    notes = notes.joins(:tags).where(tags: { id: user.tags.where(name: filters[:tag]).select(:id) }) if filters[:tag].present?
    notes.distinct
  end

  private

  def category_belongs_to_user
    return if category.nil? || category.user == user

    errors.add(:category, "must belong to the same user")
  end
end
