class CreateFlashcards < ActiveRecord::Migration[8.0]
  def change
    create_table :flashcards do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :front_content, null: false
      t.text :back_content, null: false
      t.string :flashcard_type, null: false

      t.timestamps
    end

    add_check_constraint :flashcards, "flashcard_type IN ('manual','ai','edited_ai')", name: "flashcard_type_constraint"
  end
end
