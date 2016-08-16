class CcQuestion < ActiveRecord::Base
  include Construct::Model
  include Linkable
  belongs_to :question, polymorphic: true
  belongs_to :response_unit
  has_many :maps, as: :source
  has_many :variables, through: :maps

  URN_TYPE = 'qc'
  TYPE = 'QuestionConstruct'

  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcQuestion',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        question_id: self.question_id,
        question_type: self.question_type,
        response_unit_id: self.response_unit_id
    }
  end

  def self.create_with_position(params)
    super params, true do |obj|
      obj.question_id = params[:question_id]
      obj.question_type = params[:question_type]
      obj.response_unit_id = params[:response_unit_id]
    end
  end
end
