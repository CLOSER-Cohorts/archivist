class CcStatement < ActiveRecord::Base
  include Construct::Model

  URN_TYPE = 'si'
  TYPE = 'StatementItem'

  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcStatement',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        instrument_id: self.instrument_id
    }
  end

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.literal = params[:literal]
    end
  end
end
