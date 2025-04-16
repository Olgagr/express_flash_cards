class Collection < ApplicationRecord
  has_many :flashcards_collections, dependent: :destroy
  has_many :flashcards, through: :flashcards_collections
  belongs_to :user

  validates :name, presence: true
end
