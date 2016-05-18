class CcLoop < ActiveRecord::Base
  include Construct::Model
  is_a_parent

  URN_TYPE = 'lp'
  TYPE = 'Loop'
end
