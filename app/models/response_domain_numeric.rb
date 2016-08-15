class ResponseDomainNumeric < ActiveRecord::Base
  include ResponseDomain

  def subtype
    self.numeric_type
  end

  def params
    '(' + (self.min.nil? ? '~' : '%g' % self.min) + ',' + (self.max.nil? ? '~' : '%g' % self.max) + ')'
  end
end
