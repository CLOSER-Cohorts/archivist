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

  def base_label
    cached_value('base_label') {question.label}
  end

  def response_unit_label
    cached_value('response_unit_label') {response_unit.label}
  end

  def cached_value label
    key = 'qc_question:' + label
    begin
      value = $redis.hget key, self.id
    rescue
      Rails.logger.warn 'Cannot get ' + key + ' from Redis cache'
    end
    if value.nil?
      value = yield
      unless value.nil?
        begin
          $redis.hset key, self.id, value
        rescue
          Rails.logger.warn 'Cannot set ' + key + ' to Redis cache'
        end
      end
    end
    value
  end

  def self.create_with_position(params)
    super params, true do |obj|
      obj.question_id = params[:question_id]
      obj.question_type = params[:question_type]
      obj.response_unit_id = params[:response_unit_id]
    end
  end
end
