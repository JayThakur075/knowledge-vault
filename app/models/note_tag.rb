class NoteTag < ApplicationRecord
  belongs_to :note
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :note_id }
  validate :tag_belongs_to_note_owner

  private

  def tag_belongs_to_note_owner
    return if note&.user_id == tag&.user_id

    errors.add(:tag, "must belong to the note owner")
  end
end
