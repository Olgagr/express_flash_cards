class Flashcard < ApplicationRecord
  belongs_to :user
  has_many :flashcards_collections, dependent: :destroy
  # A flashcard can belong to many collections through the join table
  has_many :collections, through: :flashcards_collections

  validates :front_content, :back_content, presence: true
  validates :flashcard_type, inclusion: { in: %w[manual ai edited_ai] }
end
