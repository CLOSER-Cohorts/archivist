class CcLoop < ApplicationRecord
  include Construct::Model

  URN_TYPE = 'lp'
  TYPE = 'Loop'

  is_a_parent

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.end_val = params[:end_val]
      obj.loop_var = params[:loop_var]
      obj.loop_while = params[:loop_while]
      obj.start_val = params[:start_val]
    end
  end

  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcLoop',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        loop_var: self.loop_var,
        start_val: self.start_val,
        end_val: self.end_val,
        loop_while: self.loop_while,
        children: self.children.map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end
end
