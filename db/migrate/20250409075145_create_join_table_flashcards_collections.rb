class CreateJoinTableFlashcardsCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :flashcards_collections do |t|
      t.references :flashcard, null: false, foreign_key: { on_delete: :cascade }
      t.references :collection, null: false, foreign_key: { on_delete: :cascade }

      t.index [ :flashcard_id, :collection_id ], unique: true
      t.index [ :collection_id, :flashcard_id ]
    end
  end
end
