module Linkable
  module Model
    extend ActiveSupport::Concern
    included do
      has_one :link, as: :target, dependent: :destroy
      has_one :topic, through: :link

      def topic=(topic)
        if topic.nil?
          self.association(:link).delete
          self.association(:topic).reload
          strand.save(true)
          return
        end

        if self.get_topic.nil? || self.get_topic == topic
          # All good
          self.association(:topic).writer(topic)
        else
          #Can still set topic if either this is the only fixed point, or we are resolving a conflict
          fixed_points = strand.get_fixed_points
          if fixed_points.count == 1
            if fixed_points.first[:point].typed_id == self.typed_id
              self.association(:topic).writer(topic)
            else
              raise Exceptions::TopicConflictError
            end
          else
            if strand.good
              raise Exceptions::TopicConflictError
            else
              self.association(:topic).writer(topic)
            end
          end
        end
        strand.save(true)
        strand.cluster.rt_update
      end

      def strand(do_cluster_compile = true)
        if (s = Strand.find_by_member(self)).nil?
          s = Strand.new([self] + self.strand_maps)
        end
        if s.id.nil? && do_cluster_compile
          c = Cluster.new [s]
          c.save
        end
        return s
      end

      def get_ancestral_topic
        if self.respond_to? :find_closest_ancestor_topic
          self.find_closest_ancestor_topic
        else
          nil
        end
      end

      def get_topic
        if @topic.nil?
          strand = Strand.find_by_member self
          strand&.topic
        else
          @topic
        end
      end

      def get_suggested_topic
        cluster = Cluster.find_by_member self
        cluster&.suggested_topic
      end

      def fully_resolved_topic_code
        (get_topic || get_suggested_topic || get_ancestral_topic)&.code&.to_s || '0'
      end
    end
  end
  module Controller
    extend ActiveSupport::Concern
    included do
      def set_topic
        topic = Topic.find_by_id params[:topic_id]

        begin
          @object.topic = topic
          @object.save!

          yield if block_given?

          render :show
        rescue Exceptions::TopicConflictError
          render json: {message: 'Could not set topic as it would cause a conflict.'}, status: :conflict
        rescue => e
          render json: e, status: :bad_request
        end
      end

      protected
      def topic_mapping(&block)
        @collection = collection.order(:id)
        @collection.each { |v| v.strand }
        respond_to &block
      end
    end
  end
end