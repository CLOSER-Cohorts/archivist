class CcSequence < ActiveRecord::Base
  include Construct::Model
  is_a_parent

  URN_TYPE = 'se'
  TYPE = 'Sequence'

  def self.create_with_position(params)
    super do |obj|
    end
  end
end
