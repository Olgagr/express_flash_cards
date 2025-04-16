class FlashcardGenerationService
  def initialize(input_text, user, collection_id)
    @input_text = input_text
    @user = user
    @collection_id = collection_id
  end

  def generate
    # Mock implementation - in real app this would call an AI service
    [
      {
        front_content: "What is the capital of France?",
        back_content: "Paris"
      },
      {
        front_content: "What is the largest planet in our solar system?",
        back_content: "Jupiter"
      }
    ]
  end
end
