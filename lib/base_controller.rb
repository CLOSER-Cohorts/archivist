module BaseController
  extend ActiveSupport::Concern
  included do
  end

  module ClassMethods
    def add_basic_actions(options = {})
      before_action :set_instrument
      before_action :set_object, only: [:show, :update, :destroy]

      class_eval <<-RUBY

        private
        def set_instrument
          @instrument = Instrument.find(params[:instrument_id])
        end

        def collection
          #{options[:collection]}
        end

        def set_object
          @object = collection.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def safe_params
          params
            .require( #{options[:require]} )
            .permit([:instrument_id] + #{options[:params]})
        end
      RUBY

      include BaseController::Actions
    end
  end

  module Actions
    def index
       @collection = collection
    end

    def show
    end

    def create
      @object = collection.new(safe_params)

      respond_to do |format|
        if @object.save
          format.json { render :show, status: :created }
        else
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @object.update(safe_params)
          format.json { render :show, status: :ok }
        else
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      begin
        @object.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      rescue
        respond_to do |format|
          format.json { head :bad_request }
        end
      end
    end
  end
end