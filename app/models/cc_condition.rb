class CcCondition < ActiveRecord::Base
  include Construct::Model
  is_a_parent branches: 2

  URN_TYPE = 'if'
  TYPE = 'IfThenElse'

  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcCondition',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        logic: self.loop_var,
        children: self.children.where(branch: 0).map { |x| {id: x.construct.id, type: x.construct.class.name} },
        fchildren: self.children.where(branch: 1).map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.literal = params[:literal]
      obj.logic = params[:logic]
    end
  end
end
