class FlashcardsController < ApplicationController
  # Rate limit the generate endpoint to prevent abuse
  rate_limit to: 10, within: 5.minutes, only: :generate, with: -> do
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("flashcard_proposals",
                                                partial: "flashcards/error_message",
                                                locals: { message: "Zbyt wiele prób generowania. Spróbuj ponownie za chwilę.", level: :warning }),
               status: :too_many_requests
      end
      format.json { render json: { error: "Too many requests. Try again later." }, status: :too_many_requests }
    end
  end

  before_action :set_collection, only: [ :new_generate, :generate, :create ]
  before_action :validate_input_text, only: :generate

  def new_generate
    # Renders the view app/views/flashcards/new_generate.html.erb
    # The @collection is set by the before_action
  end

  def generate
    # Call service to generate flashcard proposals
    proposals = FlashcardGenerationService.new(params[:input_text], Current.user, @collection.id).generate

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("flashcard_proposals",
                                                  partial: "flashcards/proposals",
                                                  locals: { proposals: proposals, collection: @collection })
      end
      format.json { render json: { proposals: proposals } }
    end
  rescue StandardError => e
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("flashcard_proposals",
                                                                      partial: "flashcards/error_message",
                                                                      locals: { message: "Wystąpił błąd: #{e.message}" }),
                                status: :internal_server_error }
      format.json { render json: { error: "An unexpected error occurred" }, status: :internal_server_error }
    end
  end

  def create
    # Build the flashcard independently first
    @flashcard = Flashcard.new(flashcard_params)
    @flashcard.user = Current.user # Explicitly assign the current user

    respond_to do |format|
      # Try saving the flashcard
      if @flashcard.save
        # If successful, add it to the collection (creates the join table record)
        @collection.flashcards << @flashcard

        format.turbo_stream do
          # Remove the proposal card and show success message
          render turbo_stream: [
            turbo_stream.remove(params[:flashcard][:proposal_dom_id]),
            turbo_stream.prepend("notifications", partial: "shared/flash", locals: { flash: { notice: "Fiszka została pomyślnie utworzona." } })
          ], status: :created
        end
        format.json { render json: @flashcard, status: :created }
      else
        format.turbo_stream do
          # Show validation errors (assuming a target frame `flashcard_form_errors` exists)
          render turbo_stream: turbo_stream.update("notifications",
                                                    partial: "shared/flash",
                                                    locals: { flash: { alert: @flashcard.errors.full_messages.to_sentence } }),
                 status: :unprocessable_entity
        end
        format.json { render json: { errors: @flashcard.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_collection
    @collection = Current.user.collections.find(params[:collection_id])
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
          render turbo_stream: turbo_stream.update("flashcard_proposals",
                                                  partial: "flashcards/error_message",
                                                  locals: { message: error_message }),
                 status: :bad_request
        end
        format.json { render json: { error: error_message }, status: :bad_request }
      end
      return false # Stop the action
    end
    true # Continue if validation passes
  end

  def flashcard_params
    params.require(:flashcard).permit(:front_content, :back_content, :flashcard_type)
  end
end
