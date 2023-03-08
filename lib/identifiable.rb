module Identifiable
  extend ActiveSupport::Concern
  included do
    has_many :identifiers, as: :item, dependent: :destroy

    def self.find_by_identifier(id_type, value)
      cache_result = $redis.hget 'identifiers', id_type + ':' + value.to_s
      if cache_result.nil?
        Identifier.includes(:item).where(item_type: self.class.name).find_by_id_type_and_value(id_type, value)&.item
      else
        return nil unless cache_result.split(':').first == self.name
        ApplicationRecord.query_typed_id cache_result
      end
    end

    def get_identifiers
      cache_result = $redis.smembers('identifier:' + self.typed_id).to_a
      if cache_result.empty?
        return self.identifiers
      else
        return cache_result
      end
    end

    def set_identifier(id_type, value)
      Identifier.create id_type: id_type, value: value, item: self
    end

    def urns
      get_identifiers.select do |x|
        x.split(':').first.downcase == 'urn'
      end.map do |x|
        x.split(':').drop(1).join(':')
      end
    end

    def add_urn(urn)
      set_identifier 'urn', urn
    end
  end
end
