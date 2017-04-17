module Linkable
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
    end

    def strand(do_cluster_compile = true)
      if (s = Strand.find_by_member(self)).nil?
        s = Strand.new [self] + self.strand_maps
      end
      if s.id.nil? && do_cluster_compile
        c = Cluster.new [s]
        c.save
      end
      return s
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
  end
end