class CcSequence < ApplicationRecord
  include Construct::Model

  URN_TYPE = 'se'
  TYPE = 'Sequence'

  is_a_parent

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
    end
  end

  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcSequence',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        children: self.children.map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end
end
