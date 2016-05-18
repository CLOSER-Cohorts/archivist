module Cache
  module Instrument
    CACHE_METHODS = [
        :question_items,
        :question_grids,
        :cc_conditions,
        :cc_loops,
        :cc_questions,
        :cc_sequences,
        :cc_statements
    ]
    module Setting
      extend ActiveSupport::Concern
      included do
        Cache::Instrument::CACHE_METHODS.each do |method|
          self.send :alias_method, ("db_" + method.to_s).to_sym, method
          self.send :define_method, ("ro_" + method.to_s).to_sym do
            collection = $redis.get 'instruments/' +  self.id.to_s + '/' + method.to_s
            if collection.nil?
              collection = self.send("db_" + method.to_s)
              $redis.set 'instruments/' +  self.id.to_s + '/' + method.to_s, collection.to_json
            else
              collection = Oj.load collection
            end
            collection
          end

          self.send :define_method, method do
            collection = self.send("db_" + method.to_s)
            unless $redis.exists 'instruments/' +  self.id.to_s + '/' + method.to_s
              $redis.set 'instruments/' +  self.id.to_s + '/' + method.to_s, collection.to_json
            end
            collection
          end
        end
      end
    end

    module Clearing
      extend ActiveSupport::Concern
      included do
        after_commit :clear_instrument_level_caching
        def clear_instrument_level_caching
          $redis.del 'instruments/' +  self.instrument.id.to_s + '/' + self.class.name.tableize
        end
      end
    end
  end
end