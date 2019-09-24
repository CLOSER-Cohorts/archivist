module Linkable
  module Model
    extend ActiveSupport::Concern
    included do
      has_one :link, as: :target, dependent: :destroy
      has_one :topic, through: :link

      def get_ancestral_topic
        if self.respond_to? :find_closest_ancestor_topic
          self.find_closest_ancestor_topic
        else
          nil
        end
      end

      def fully_resolved_topic_code
        (topic || get_ancestral_topic)&.code&.to_s || '0'
      end
    end
  end
  module Controller
    extend ActiveSupport::Concern
    included do
      def set_topic
        topic = Topic.find_by_id params[:topic_id]

        begin
          ActiveRecord::Base.transaction do
            @object.topic = topic
            @object.save!
          end

          yield if block_given?

          render :show
        rescue Exceptions::TopicConflictError
          render json: {message: 'Could not set topic as it would cause a conflict.'}, status: :conflict
        rescue => e
          render json: {message: e.message}, status: :conflict
        end
      end

      protected
      def topic_mapping(&block)
        @collection = collection.order(:id)
        respond_to(&block)
      end
    end
  end
end
