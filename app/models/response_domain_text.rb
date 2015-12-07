class ResponseDomainText < ActiveRecord::Base
  include ResponseDomain
  belongs_to :instrument
end
