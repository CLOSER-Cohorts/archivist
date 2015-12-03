class ResponseDomainCode < ActiveRecord::Base
  include ResponseDomain
  belongs_to :code_list
end
