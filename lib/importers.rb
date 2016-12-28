module Importers
  module Controller
    extend ActiveSupport::Concern
    included do
      def member_imports
        binding.pry
        1
        imports = params[:imports].nil? ? [] : params[:imports]
        head :ok, format: :json if imports.empty?
        begin
          imports.each do |import|
            doc = Document.new file: import[:file]
            doc.save_or_get

            type = import[:type]&.downcase&.to_sym

            Resque.enqueue class_variable_get(:@@map)[type], doc.id, @object
          end
          head :ok, format: :json
        rescue  => e
          render json: {message: e}, status: :bad_request
        end
      end
    end

    class_methods do
      def has_importers(map)
        class_variable_set :@@map, map
      end
    end
  end
end
