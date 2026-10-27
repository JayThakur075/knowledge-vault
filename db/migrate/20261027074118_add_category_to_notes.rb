class AddCategoryToNotes < ActiveRecord::Migration[8.1]
  def change
    add_reference :notes, :category, foreign_key: true
  end
end
