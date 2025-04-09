class CreateStats < ActiveRecord::Migration[8.0]
  def change
    create_table :stats do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.integer :manual_flashcards_count, null: false, default: 0
      t.integer :ai_flashcards_count, null: false, default: 0
      t.integer :edited_ai_flashcards_count, null: false, default: 0

      t.timestamps
    end
  end
end
