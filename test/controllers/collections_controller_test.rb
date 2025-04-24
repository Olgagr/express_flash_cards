require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Assuming you have a fixture named :one in users.yml
    @collection = collections(:one) # Assuming you have a fixture named :one in collections.yml associated with user :one

    post session_url, params: { email_address: @user.email_address, password: "password" }
    assert_response :redirect
  end

  test "should get index" do
    get collections_url
    assert_response :success
    assert_not_nil assigns(:collections) # Check if @collections instance variable is assigned
  end

  test "should show collection" do
    get collection_url(@collection)
    assert_response :success
    assert_not_nil assigns(:collection) # Check if @collection instance variable is assigned
    assert_not_nil assigns(:flashcards) # Check if @flashcards instance variable is assigned
  end

  test "should get new" do
    get new_collection_url
    assert_response :success
    assert_instance_of Collection, assigns(:collection) # Check if @collection is a new Collection instance
  end

  test "should get edit" do
    get edit_collection_url(@collection)
    assert_response :success
    assert_not_nil assigns(:collection) # Check if @collection instance variable is assigned
  end

  test "should create collection" do
    assert_difference("Collection.count") do
      post collections_url, params: { collection: { name: "New Test Collection" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_turbo_stream action: "append", target: "collections_list"
    assert_match /New Test Collection/, @response.body
  end

  test "should update collection" do
    patch collection_url(@collection), params: { collection: { name: "Updated Collection Name" } }, as: :turbo_stream

    # Check for Turbo Stream response
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_match /turbo-stream/, response.body
    assert_turbo_stream action: "replace", target: dom_id(@collection)

    @collection.reload
    assert_equal "Updated Collection Name", @collection.name
  end

  test "should destroy collection" do
    assert_difference("Collection.count", -1) do
      delete collection_url(@collection), as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    # Check that the turbo stream removes the correct element
    assert_turbo_stream action: "remove", target: dom_id(@collection)
  end
end
