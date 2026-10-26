class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :note_type
      t.boolean :favorite

      t.timestamps
    end
  end
end
