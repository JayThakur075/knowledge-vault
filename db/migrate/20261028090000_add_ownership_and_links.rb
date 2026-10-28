class AddOwnershipAndLinks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tags, :user, foreign_key: true

    create_table :links do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.text :description
      t.timestamps
    end

    add_index :links, [ :user_id, :url ]
    create_table :link_tags do |t|
      t.references :link, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :link_tags, [ :link_id, :tag_id ], unique: true
  end
end
