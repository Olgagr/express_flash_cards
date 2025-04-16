class CollectionsController < ApplicationController
  # Find the collection for specific actions, scoped to the current user
  before_action :set_collection, only: [ :show, :edit, :update, :destroy ]

  # GET /collections
  def index
    @collections = Current.user.collections.order(created_at: :desc)
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
    # @collection is set by before_action :set_collection
  end

  # POST /collections
  def create
    @collection = Current.user.collections.build(collection_params)

    respond_to do |format|
      if @collection.save
        # For Turbo Stream, flash is set in the .turbo_stream.erb template
        format.turbo_stream
        format.html { redirect_to collections_path, notice: "Kolekcja została pomyślnie utworzona." }
      else
        format.turbo_stream do
          # Re-render the modal with errors
          render turbo_stream: turbo_stream.update("modal",
                                                    partial: "collections/form_modal",
                                                    locals: { collection: @collection }),
                 status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  def update
    # @collection is set by before_action :set_collection
    respond_to do |format|
      if @collection.update(collection_params)
        # For Turbo Stream, flash is set in the .turbo_stream.erb template
        format.turbo_stream
        format.html { redirect_to collections_path, notice: "Kolekcja została pomyślnie zaktualizowana." }
      else
        format.turbo_stream do
          # Re-render the modal with errors
          render turbo_stream: turbo_stream.update("modal",
                                                    partial: "collections/form_modal",
                                                    locals: { collection: @collection }),
                 status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  def destroy
    # @collection is set by before_action :set_collection
    @collection.destroy

    respond_to do |format|
      # For Turbo Stream, flash is set in the .turbo_stream.erb template
      # Pass current_user to the stream template for the empty check
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@collection), locals: { current_user: Current.user } }
      format.html { redirect_to collections_url, notice: "Kolekcja została pomyślnie usunięta." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Current.user.collections.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # Handle case where collection not found or doesn't belong to user
      redirect_to collections_path, alert: "Nie znaleziono kolekcji."
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name)
    end
end
