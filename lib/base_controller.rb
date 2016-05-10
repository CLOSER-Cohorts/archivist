module BaseController
  extend ActiveSupport::Concern
  included do
    after_action :verify_policy_scoped, only: :index
    before_action :authenticate_user!
  end
  module ClassMethods
    def add_basic_actions(options = {})
      options[:only] ||= []
      before_action :set_object, only: [:show, :update, :destroy] + options[:only]

      class_eval <<-RUBY

        private

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
            .permit( #{options[:params]} )
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
      if @object.save
        render :show, status: :created
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    def update
      if @object.update(safe_params)
        render :show, status: :ok
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end

    def destroy
      begin
        @object.destroy
        head :no_content
      rescue
        head :bad_request
      end
    end
  end
end