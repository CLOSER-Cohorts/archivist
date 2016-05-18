module ActiveSupport::JSON::Encoding
  class Oj < JSONGemEncoder
    def encode value
      ::Oj.dump(value.as_json)
    end
  end
end

Oj.default_options = {time_format: :unix, mode: :compat}

ActiveSupport.json_encoder = ActiveSupport::JSON::Encoding::Oj
MultiJson.use :oj