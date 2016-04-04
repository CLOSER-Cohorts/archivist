class CcSequence < ActiveRecord::Base
  include Construct
  is_a_parent

  URN_TYPE = 'se'
  TYPE = 'Sequence'
end
