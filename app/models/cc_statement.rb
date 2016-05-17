class CcStatement < ActiveRecord::Base
  include Construct::Model

  URN_TYPE = 'si'
  TYPE = 'StatementItem'
end
