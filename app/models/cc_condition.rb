class CcCondition < ActiveRecord::Base
  include Construct::Model
  is_a_parent branches: 2

  URN_TYPE = 'if'
  TYPE = 'IfThenElse'

  def self.create_with_position(params)
    super do |obj|
      obj.literal = params[:literal]
      obj.logic = params[:logic]
    end
  end
end
