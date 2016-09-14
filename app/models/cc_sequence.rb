class CcSequence < ActiveRecord::Base
  include Construct::Model
  is_a_parent

  URN_TYPE = 'se'
  TYPE = 'Sequence'

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

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
    end
  end
end
