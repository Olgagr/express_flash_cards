class Collection < ApplicationRecord
  has_many :flashcards, through: :flashcards_collections
  has_many :flashcards_collections
  belongs_to :user

  validates :name, presence: true
end
