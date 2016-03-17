class CcStatement < ActiveRecord::Base
  include Construct

  URN_TYPE = 'si'
  TYPE = 'StatementItem'
end
