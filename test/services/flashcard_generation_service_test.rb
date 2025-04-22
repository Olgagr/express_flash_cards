# frozen_string_literal: true

require "test_helper"
require "minitest/mock" # Required for Minitest::Mock

# Define the custom error class if it's not globally available
# This might be needed if the error class isn't loaded during testing yet.
# If OpenRouterService and its errors are autoloaded correctly, you might not need this.


class FlashcardGenerationServiceTest < ActiveSupport::TestCase
  setup do
    @input_text = "Sample text for flashcards."
    # Replace with your actual user/collection setup (fixtures or factories)
    @user = users(:one)
    @collection = collections(:one)
    @service = FlashcardGenerationService.new(@input_text, @user, @collection.id)

    # Create a mock instance for OpenRouterService for each test
    @mock_open_router_service = Minitest::Mock.new
  end

  test "generate success returns parsed flashcards" do
    expected_response_json = '[{"front_content": "Q1", "back_content": "A1"}, {"front_content": "Q2", "back_content": "A2"}]'
    expected_flashcards = [ { "front_content" => "Q1", "back_content" => "A1" }, { "front_content" => "Q2", "back_content" => "A2" } ]

    # Expect send_chat_message to be called once and return the successful response
    @mock_open_router_service.expect(
      :send_chat_message,
      { response: expected_response_json },
      user_message: @input_text
    )

    # Stub OpenRouterService.new to return our mock instance
    # We also check the system message argument implicitly via the lambda's signature check,
    # but a more explicit check could be added inside the lambda if needed.
    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      actual_flashcards = @service.generate
      assert_equal expected_flashcards, actual_flashcards
    end

    # Verify that all expectations on the mock were met
    @mock_open_router_service.verify
  end

  test "generate handles open_router_api_error" do
    # Instantiate the error using the expected signature (likely one hash arg)
    # Include the desired message within the details hash.
    error_details = { message: "API Failed", status: 500, detail: "Internal Server Error" }
    api_error = OpenRouterService::ApiError.new(error_details)

    # Expect send_chat_message to be called and raise the error
    @mock_open_router_service.expect(:send_chat_message, nil) do |user_message:|
      raise api_error
    end

    # Expect Rails.logger.error to be called with a message matching the error details
    # Ensure the regex matches the message extracted from the details hash ("API Failed")
    log_pattern = /FlashcardGenerationService: OpenRouter API error - OpenRouterService::ApiError: {:message=>\"API Failed\", :status=>500, :detail=>\"Internal Server Error\"} Details: {}/

    # Flag to check if logger was called
    log_was_called = false

    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      # Stub Rails.logger.error directly
      Rails.logger.stub :error, ->(msg) {
        assert_match log_pattern, msg
        log_was_called = true
      } do
        # Use assert_logs to check for the specific error message
        # assert_logs :error, log_pattern do # <-- Remove assert_logs
        actual_flashcards = @service.generate
        assert_equal [], actual_flashcards, "Should return an empty array on API error"
        # end
      end
    end
    # Assert that the logger stub was actually called
    assert log_was_called, "Expected Rails.logger.error to be called"

    @mock_open_router_service.verify
  end

  test "generate handles nil response from open_router" do
    error_message = "Service timed out"
    # Expect send_chat_message to return a nil response payload
    @mock_open_router_service.expect(
      :send_chat_message,
      { response: nil, error: error_message },
      user_message: @input_text
    )

    # Rails.logger.expects(:error).with("FlashcardGenerationService: Failed to get response from OpenRouter. Error: #{error_message}")
    log_message = "FlashcardGenerationService: Failed to get response from OpenRouter. Error: #{error_message}"
    log_was_called = false

    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      # Use assert_logs to check for the specific error message
      # assert_logs :error, log_message do
      Rails.logger.stub :error, ->(msg) {
        assert_equal log_message, msg
        log_was_called = true
      } do
        actual_flashcards = @service.generate
        assert_equal [], actual_flashcards, "Should return an empty array on nil response"
      end
    end
    assert log_was_called, "Expected Rails.logger.error to be called"

    @mock_open_router_service.verify
  end

  test "generate handles malformed json response" do
    malformed_json = '{"front_content": "Q1", "back_content": "A1"' # Missing closing brace

    @mock_open_router_service.expect(
      :send_chat_message,
      { response: malformed_json },
      user_message: @input_text
    )

    # Expect logger message indicating JSON parsing failed
    # Rails.logger.expects(:error).with(regexp_matches(/FlashcardGenerationService: Failed to parse JSON response from OpenRouter:.*Response: #{Regexp.escape(malformed_json)}/))
    log_pattern = /FlashcardGenerationService: Failed to parse JSON response from OpenRouter:.*Response: #{Regexp.escape(malformed_json)}/
    log_was_called = false

    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      # Use assert_logs to check for the specific error message
      # assert_logs :error, log_pattern do
      Rails.logger.stub :error, ->(msg) {
        assert_match log_pattern, msg
        log_was_called = true
      } do
        actual_flashcards = @service.generate
        assert_equal [], actual_flashcards, "Should return an empty array on JSON::ParserError"
      end
    end
    assert log_was_called, "Expected Rails.logger.error to be called"

    @mock_open_router_service.verify
  end

  test "generate handles non_array json response" do
    non_array_json = '{"message": "This is not an array"}'

    @mock_open_router_service.expect(
      :send_chat_message,
      { response: non_array_json },
      user_message: @input_text
    )

    # Rails.logger.expects(:error).with("FlashcardGenerationService: AI response was not a JSON array: #{non_array_json}")
    log_message = "FlashcardGenerationService: AI response was not a JSON array: #{non_array_json}"
    log_was_called = false

    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      # Use assert_logs to check for the specific error message
      # assert_logs :error, log_message do
      Rails.logger.stub :error, ->(msg) {
        assert_equal log_message, msg
        log_was_called = true
      } do
        actual_flashcards = @service.generate
        assert_equal [], actual_flashcards, "Should return an empty array if JSON is not an array"
      end
    end
    assert log_was_called, "Expected Rails.logger.error to be called"

    @mock_open_router_service.verify
  end

  test "generate handles empty array json response" do
    empty_array_json = "[]"

    @mock_open_router_service.expect(
      :send_chat_message,
      { response: empty_array_json },
      user_message: @input_text
    )

    # Ensure no error logs related to parsing or type validation are triggered
    # Rails.logger.expects(:error).never

    OpenRouterService.stub :new, ->(system_message:) { @mock_open_router_service } do
      # Use assert_no_logs to ensure no error was logged
      # assert_no_logs :error do
      # Use stub with flunk to ensure logger.error is never called
      Rails.logger.stub :error, ->(msg) { flunk "Rails.logger.error should not have been called, but received: #{msg}" } do
        actual_flashcards = @service.generate
        assert_equal [], actual_flashcards, "Should return an empty array for an empty JSON array response"
      end
    end

    @mock_open_router_service.verify
  end
end
