class FlashcardsCollection < ApplicationRecord
  belongs_to :flashcard
  belongs_to :collection
end
