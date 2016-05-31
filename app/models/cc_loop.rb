class CcLoop < ActiveRecord::Base
  include Construct::Model
  is_a_parent

  URN_TYPE = 'lp'
  TYPE = 'Loop'

  def self.create_with_position(params)
    super do |obj|
      obj.end_val = params[:end_val]
      obj.loop_var = params[:loop_var]
      obj.loop_while = params[:loop_while]
      obj.start_val = params[:start_val]
    end
  end
end
