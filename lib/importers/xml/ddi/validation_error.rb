
module Importers::XML::DDI
  class ValidationError < ActiveRecord::RecordInvalid
    attr_accessor :input

    def initialize(input = '', record = nil)
      @input = input

      super(record)
    end
  end
end