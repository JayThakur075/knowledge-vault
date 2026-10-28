class LinkTag < ApplicationRecord
  belongs_to :link
  belongs_to :tag
  validates :tag_id, uniqueness: { scope: :link_id }
  validate :tag_belongs_to_link_owner

  private

  def tag_belongs_to_link_owner
    return if link&.user_id == tag&.user_id

    errors.add(:tag, "must belong to the link owner")
  end
end
