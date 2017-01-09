module Exportable
  extend ActiveSupport::Concern
  included do
    def urn(urn_prefix = nil)
      urn_prefix = ['urn', 'ddi', self.instrument.agency, self.instrument.prefix].join ':' if urn_prefix.nil?
      [urn_prefix, self.class::URN_TYPE, '%06d:1.0.0' % self.id].compact.join '-'
    end
  end
end