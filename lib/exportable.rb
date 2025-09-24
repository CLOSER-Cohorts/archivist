module Exportable
  extend ActiveSupport::Concern

  class_methods do
    def tag
      [self::NS, self::TYPE].join ':'
    end
  end

  included do

    after_commit :set_ddi_slug, on: :create

    def urn=(value)
      return unless value
      value.match(/urn:ddi:(?<instrument_agency>.*):(?<instrument_prefix>.*)-(?<type>.*)-(?<id>.*):(.*)/)
      self.ddi_slug = pad_to_six_chars($~[:id])
    end

    def urn(urn_prefix = nil, urn_type = nil)
      instrument = (self.is_a?(Instrument)) ? self : self.instrument
      urn_prefix = ['urn', 'ddi', instrument.agency, instrument.prefix].join ':' if urn_prefix.nil?
      urn_type = self.class::URN_TYPE if urn_type.nil?
      # Use ddi_slug instead of id
      [urn_prefix, urn_type, "#{pad_to_six_chars(self.ddi_slug || self.id)}:1.0.0"].compact.join '-'
    end

    def exploded_urn
      @exploded_urn ||= OpenStruct.new(
        agency: self.instrument.agency,
        version: '1.0.0',
        # Use ddi_slug instead of id
        id: [self.instrument.prefix, self.class::URN_TYPE, self.ddi_slug].compact.join('-'),
        type_of_object: self.class.name
      )
    end

    def set_ddi_slug
      return unless self.ddi_slug.blank?
      self.update_column :ddi_slug, self.id
    end

    def pad_to_six_chars(input)
      input.to_s.rjust(6, '0')
    end    
  end
end
