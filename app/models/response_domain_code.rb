class ResponseDomainCode < ActiveRecord::Base
  include ResponseDomain
  belongs_to :code_list
  delegate :instrument, to: :code_list
  delegate :label, to: :code_list
end
