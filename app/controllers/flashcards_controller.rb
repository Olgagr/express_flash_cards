class FlashcardsController < ApplicationController
  # Rate limit the generate endpoint to prevent abuse
  rate_limit to: 10, within: 5.minutes, only: :generate, with: -> do
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("flashcard_proposals",
                                                html: "<div class=\"text-yellow-700 p-4 border border-yellow-300 rounded bg-yellow-50\">Zbyt wiele prób generowania. Spróbuj ponownie za chwilę.</div>".html_safe),
               status: :too_many_requests
      end
      format.json { render json: { error: "Too many requests. Try again later." }, status: :too_many_requests }
    end
  end

  before_action :set_collection, only: [ :new_generate, :generate ]
  before_action :validate_input_text, only: :generate

  def new_generate
    # Renders the view app/views/flashcards/generate.html.erb
    # The @collection is set by the before_action
  end

  def generate
    # Call service to generate flashcard proposals
    proposals = FlashcardGenerationService.new(params[:input_text], Current.user, @collection.id).generate

    # Return proposals in the specified format
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("flashcard_proposals",
                                                  partial: "flashcards/proposals",
                                                  locals: { proposals: proposals, collection: @collection })
      end
      format.json { render json: { proposals: proposals } }
    end
  rescue StandardError => e
    # Handle errors - render turbo_stream with error message
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flashcard_proposals", html: "<div class=\"text-red-500 p-4 border border-red-300 rounded bg-red-50\">Wystąpił błąd: #{e.message}</div>".html_safe), status: :internal_server_error }
      format.json { render json: { error: "An unexpected error occurred" }, status: :internal_server_error }
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:collection_id])
    # Add authorization check if needed, e.g., authorize! :read, @collection
  rescue ActiveRecord::RecordNotFound
    redirect_to collections_path, alert: "Collection not found." # Or render a 404 page
  end

  def validate_input_text
    input_text = params[:input_text]
    error_message = nil

    if !input_text.present?
      error_message = "Tekst do wygenerowania fiszek nie może być pusty."
    elsif input_text.length > 1000
      error_message = "Tekst nie może przekraczać 1000 znaków."
    end

    if error_message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flashcard_proposals",
                                                  html: "<div class=\"text-red-500 p-4 border border-red-300 rounded bg-red-50\">#{error_message}</div>".html_safe),
                 status: :bad_request
        end
        format.json { render json: { error: error_message }, status: :bad_request }
      end
      return false # Stop the action
    end
    true # Continue if validation passes
  end
end
