class ResponseDomainDatetime < ApplicationRecord
  include ResponseDomain

  def subtype
    self.datetime_type
  end

  def params
    '(' + self.format.to_s + ')'
  end
end
