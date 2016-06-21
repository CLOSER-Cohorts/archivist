class CcStatement < ActiveRecord::Base
  include Construct::Model

  URN_TYPE = 'si'
  TYPE = 'StatementItem'

  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.literal = params[:literal]
    end
  end
end
