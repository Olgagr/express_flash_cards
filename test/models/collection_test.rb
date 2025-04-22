require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    # Assuming you have fixtures set up for users
    @user = users(:one) # Adjust if your user fixture has a different name
  end

  test "should be valid with a name and user" do
    collection = Collection.new(name: "Test Collection", user: @user)
    assert collection.valid?
  end

  test "should be invalid without a name" do
    collection = Collection.new(user: @user)
    assert_not collection.valid?
    assert_includes collection.errors[:name], "can't be blank"
  end

  test "should be invalid without a user" do
    collection = Collection.new(name: "Test Collection")
    assert_not collection.valid?
    assert_includes collection.errors[:user], "must exist"
  end

  test "should belong to a user" do
    collection = Collection.new(name: "Test Collection", user: @user)
    assert_respond_to collection, :user
    assert_instance_of User, collection.user
  end

  test "should have many flashcards" do
    collection = Collection.new(name: "Test Collection", user: @user)
    assert_respond_to collection, :flashcards
    assert_respond_to collection, :flashcards_collections
  end

  test "dependent flashcards_collections should be destroyed" do
    # Assuming you have fixtures for collections and flashcards_collections
    collection = collections(:one) # Adjust fixture name if needed
    assert_difference("FlashcardsCollection.count", -collection.flashcards_collections.count) do
      collection.destroy
    end
  end
end
