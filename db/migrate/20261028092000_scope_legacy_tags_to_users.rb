class ScopeLegacyTagsToUsers < ActiveRecord::Migration[8.1]
  class LegacyTag < ActiveRecord::Base
    self.table_name = "tags"
  end

  class LegacyNoteTag < ActiveRecord::Base
    self.table_name = "note_tags"
  end

  class LegacyNote < ActiveRecord::Base
    self.table_name = "notes"
  end

  class LegacyLinkTag < ActiveRecord::Base
    self.table_name = "link_tags"
  end

  class LegacyLink < ActiveRecord::Base
    self.table_name = "links"
  end

  class UnassignedLegacyTag < ActiveRecord::Base
    self.table_name = "legacy_unassigned_tags"
  end

  def up
    remove_index :tags, :name, unique: true
    create_table :legacy_unassigned_tags, id: false do |t|
      t.integer :id, primary_key: true
      t.string :name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    LegacyTag.where(user_id: nil).find_each do |tag|
      note_associations = LegacyNoteTag.where(tag_id: tag.id)
      link_associations = LegacyLinkTag.where(tag_id: tag.id)
      user_ids = LegacyNote.where(id: note_associations.select(:note_id)).distinct.pluck(:user_id)
      user_ids |= LegacyLink.where(id: link_associations.select(:link_id)).distinct.pluck(:user_id)

      if user_ids.empty?
        UnassignedLegacyTag.create!(id: tag.id, name: tag.name, created_at: tag.created_at, updated_at: tag.updated_at)
        tag.destroy!
        next
      end

      user_ids.each_with_index do |user_id, index|
        user_tag = if index.zero?
          tag.update!(user_id: user_id)
          tag
        else
          LegacyTag.find_or_create_by!(name: tag.name, user_id: user_id)
        end
        note_ids = LegacyNote.where(user_id: user_id).select(:id)
        link_ids = LegacyLink.where(user_id: user_id).select(:id)
        reassign_associations(LegacyNoteTag, :note_id, note_associations.where(note_id: note_ids), user_tag.id)
        reassign_associations(LegacyLinkTag, :link_id, link_associations.where(link_id: link_ids), user_tag.id)
      end
    end

    change_column_null :tags, :user_id, false
    add_index :tags, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :tags, [ :user_id, :name ]

    LegacyTag.order(:id).group_by(&:name).each_value do |tags|
      canonical_tag, *duplicates = tags
      duplicates.each do |duplicate|
        merge_associations(LegacyNoteTag, :note_id, duplicate.id, canonical_tag.id)
        merge_associations(LegacyLinkTag, :link_id, duplicate.id, canonical_tag.id)
        duplicate.destroy!
      end
    end

    change_column_null :tags, :user_id, true
    LegacyTag.update_all(user_id: nil)
    if table_exists?(:legacy_unassigned_tags)
      UnassignedLegacyTag.find_each do |tag|
        LegacyTag.create!(id: tag.id, name: tag.name, created_at: tag.created_at, updated_at: tag.updated_at) unless LegacyTag.exists?(name: tag.name)
      end
      drop_table :legacy_unassigned_tags
    end
    add_index :tags, :name, unique: true
  end

  private

  def reassign_associations(join_model, record_key, associations, new_tag_id)
    associations.find_each do |association|
      next if association.tag_id == new_tag_id

      existing = join_model.exists?(record_key => association.public_send(record_key), tag_id: new_tag_id)
      existing ? association.destroy! : association.update!(tag_id: new_tag_id)
    end
  end

  def merge_associations(join_model, record_key, old_tag_id, new_tag_id)
    reassign_associations(join_model, record_key, join_model.where(tag_id: old_tag_id), new_tag_id)
  end
end
