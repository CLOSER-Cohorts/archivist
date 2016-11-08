class ResponseDomainText < ApplicationRecord
  include ResponseDomain

  def params
    self.maxlen.nil? ? '' : '(' + '%g' % self.maxlen + ')'
  end
end
