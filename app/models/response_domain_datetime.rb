class ResponseDomainDatetime < ActiveRecord::Base
  include ResponseDomain
  belongs_to :instrument
end
