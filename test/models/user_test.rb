require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(email_address: "valid@example.com", password: "password", password_confirmation: "password")
    assert user.valid?
  end

  test "should normalize email address to downcase and strip whitespace" do
    # Use create to trigger callbacks/normalization before assertion
    user = User.create(email_address: "  TeSt@ExAmPlE.cOm  ", password: "password", password_confirmation: "password")
    assert_equal "test@example.com", user.email_address
  end

  test "should be invalid without email address" do
    user = User.new(password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should be invalid with invalid email format" do
    user = User.new(email_address: "invalid-email", password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "should be invalid with duplicate email address (case-insensitive)" do
    existing_user = users(:one) # From fixtures test/fixtures/users.yml
    user = User.new(email_address: existing_user.email_address.upcase, password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should be invalid without password on creation" do
    user = User.new(email_address: "another_test@example.com")
    # has_secure_password validation adds presence validation for password
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should be invalid with password shorter than 6 characters" do
    user = User.new(email_address: "shortpass@example.com", password: "123", password_confirmation: "123")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "should be valid when updating attributes without changing password" do
    user = users(:one)
    # allow_nil: true for password validation allows this
    assert user.update(email_address: "new_email@example.com")
    assert_equal "new_email@example.com", user.reload.email_address
  end

  test "should be valid when updating password with valid length" do
     user = users(:one)
     assert user.update(password: "newpassword", password_confirmation: "newpassword")
     # Verify the new password works
     assert user.authenticate("newpassword")
   end

  test "should be invalid when updating password with too short password" do
    user = users(:one)
    assert_not user.update(password: "short", password_confirmation: "short")
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
    # Ensure password hasn't actually changed
    assert user.reload.authenticate("password")
  end

  test "should authenticate with correct password" do
    user = users(:one) # Uses password 'password' from fixture
    assert user.authenticate("password")
  end

  test "should not authenticate with incorrect password" do
    user = users(:one)
    assert_not user.authenticate("wrongpassword")
  end

  # Test dependent: :destroy associations
  # These assume Session and Collection models exist and can be created simply.
  # You might need Session/Collection fixtures or adjust creation based on their validations.

  # Setup method to ensure related models exist if needed
  # def setup
  #   # Create sample Session and Collection models if they don't have fixtures
  #   # e.g., Session.create!(...) unless Session.exists?(...)
  # end

  test "should destroy associated sessions when user is destroyed" do
    user = users(:one)
    # Ensure associated models exist for the test
    # Replace with fixture loading if you create session fixtures
    user.sessions.create! # Assuming Session model has no required attributes or defaults

    assert_difference("Session.count", -1) do
      user.destroy
    end
  end

  test "should destroy associated collections when user is destroyed" do
    user = users(:one)
    # Ensure associated models exist for the test
    # Replace with fixture loading if you create collection fixtures
    user.collections.create!(name: "Test Collection") # Assuming Collection requires a name

    assert_difference("Collection.count", -1) do
      user.destroy
    end
  end
end
