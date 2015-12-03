class CodeList < ActiveRecord::Base
  has_many :codes, dependent: :destroy
  has_many :categories, through: :codes
  has_one :response_domain_code, dependent: :destroy

  def response_domain
    self.response_domain_code
  end

  def response_domain=(be_code_answer)
    if be_code_answer && response_domain.nil?
      self.response_domain_code = ResponseDomainCode.create
    end

    if  !(be_code_answer || response_domain.nil?)
      self.response_domain_code.destroy
    end
  end
end
