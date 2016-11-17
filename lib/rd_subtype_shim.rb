module RdSubtypeShim
  extend ActiveSupport::Concern
  included do
    before_action :subtype_shim, only: [:create, :update]
    def subtype_shim
      self.params[
          self
              .class
              .model_class
              .name
              .underscore
              .to_sym
      ][subtype] = self.params[:subtype]
    end
  end

  class_methods do
    def permit_subtype(stype)
      define_method 'subtype' do
        stype
      end
    end
  end
end