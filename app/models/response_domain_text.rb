class ResponseDomainText < ActiveRecord::Base
  include ResponseDomain

  def params
    self.maxlen.nil? ? '' : '(' + '%g' % self.maxlen + ')'
  end
end
