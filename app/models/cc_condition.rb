class CcCondition < ActiveRecord::Base
  include Construct
  is_a_parent branches: 2
end
