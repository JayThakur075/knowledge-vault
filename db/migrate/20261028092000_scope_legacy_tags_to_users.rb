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

  def up
    remove_index :tags, :name, unique: true
    LegacyTag.where(user_id: nil).find_each do |tag|
      associations = LegacyNoteTag.where(tag_id: tag.id)
      user_ids = LegacyNote.where(id: associations.select(:note_id)).distinct.pluck(:user_id)

      if user_ids.empty?
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
        LegacyNoteTag.where(id: associations.where(note_id: LegacyNote.where(user_id: user_id).select(:id)).select(:id)).update_all(tag_id: user_tag.id)
      end
    end

    change_column_null :tags, :user_id, false
    add_index :tags, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :tags, [ :user_id, :name ]
    change_column_null :tags, :user_id, true
  end
end
