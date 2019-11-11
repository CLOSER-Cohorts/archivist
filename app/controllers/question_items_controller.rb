# A controller for the model {QuestionItem}
class QuestionItemsController < QuestionController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = QuestionItem

  # List of params that can be set and edited
  @params_list = [:literal, :label, :instruction_id]

  def index
    @response_domain_codes = @instrument.response_domain_codes.includes(:codes)
    @response_domain_datetimes = @instrument.response_domain_datetimes
    @response_domain_numerics = @instrument.response_domain_numerics
    @response_domain_texts = @instrument.response_domain_texts
    super
  end

  def collection
    @instrument.question_items.includes(:rds_qs)
  end
end
