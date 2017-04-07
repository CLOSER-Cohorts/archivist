class ResponseDomainDatetime < ApplicationRecord
  include ResponseDomain

  def subtype
    self.datetime_type
  end

  def params
    '(%s)' % @format
  end
end
