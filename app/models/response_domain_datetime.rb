class ResponseDomainDatetime < ActiveRecord::Base
  include ResponseDomain

  def subtype
    self.datetime_type
  end

  def params
    '(' + self.format.to_s + ')'
  end
end
