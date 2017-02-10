module Mappable
  extend ActiveSupport::Concern
  included do
    def typed_id
      self.class.name + ':' + self.id.to_s
    end

    def get_strand
      s = Strand.find_by_member self
      if s.nil?
        s = Strand.new [self]
      end
      return s
    end
  end
end