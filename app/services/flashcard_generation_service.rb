# frozen_string_literal: true

class FlashcardGenerationService
  def initialize(input_text, user, collection_id)
    @input_text = input_text
    @user = user
    @collection_id = collection_id
  end

  def generate
    open_router_service = OpenRouterService.new(
      system_message: <<~MESSAGE
        You are an assistant that generates flashcards based on the provided text.
        Create flashcards with a front (question/term) and a back (answer/definition).
        Return the flashcards as a JSON array where each object has 'front_content' and
        'back_content' keys. Return only the JSON array, nothing else.

        <example>
          USER: Faraday is an HTTP client library abstraction layer that provides a common interface over many adapters.
          ASSISTANT: [
            {
              "front_content": "What is Faraday?",
              "back_content": "HTTP client library abstraction layer"
            },
            {
              "front_content": "What Faraday provides?",
              "back_content": "A common interface over many adapters"
            }
          ]
        </example>
      MESSAGE
    )

    begin
      response_data = open_router_service.send_chat_message(user_message: @input_text)

      # TODO: Implement robust parsing and validation of the response_data[:response]
      # For now, assume the response is the expected JSON string or handle basic errors.
      if response_data[:response].nil?
        Rails.logger.error("FlashcardGenerationService: Failed to get response from OpenRouter. Error: #{response_data[:error]}")
        # Return an empty array or raise a specific error
        return []
      end

      # Attempt to parse the JSON response from the AI model
      begin
        flashcards = JSON.parse(response_data[:response])
        # Basic validation: check if it's an array
        unless flashcards.is_a?(Array)
          Rails.logger.error("FlashcardGenerationService: AI response was not a JSON array: #{response_data[:response]}")
          return [] # Or raise an error
        end
        flashcards
      rescue JSON::ParserError => e
        Rails.logger.error("FlashcardGenerationService: Failed to parse JSON response from OpenRouter: #{e.message}. Response: #{response_data[:response]}")
        # Return empty or raise
        []
      end

    rescue OpenRouterService::ApiError => e
      Rails.logger.error("FlashcardGenerationService: OpenRouter API error - #{e.class}: #{e.message} Details: #{e.details}")
      # Decide how to handle API errors, e.g., return empty array, raise error, etc.
      [] # For now, return empty on error
    end
  end
end
