class FlashcardsController < ApplicationController
  # Rate limit the generate endpoint to prevent abuse
  rate_limit to: 10, within: 5.minutes, only: :generate, with: -> { render json: { error: "Too many requests. Try again later." }, status: :too_many_requests }

  before_action :validate_input_text, only: :generate

  def generate
    # Call service to generate flashcard proposals
    proposals = FlashcardGenerationService.new(params[:input_text], Current.user, params[:collection_id]).generate

    # Return proposals in the specified format
    render json: { proposals: proposals }
  rescue StandardError => e
    render json: { error: "An unexpected error occurred" }, status: :internal_server_error
  end

  private

  def validate_input_text
    unless params[:input_text].present?
      render json: { error: "input_text is required" }, status: :bad_request
      return
    end

    if params[:input_text].length > 1000
      render json: { error: "input_text cannot exceed 1000 characters" }, status: :bad_request
      nil
    end
  end
end
