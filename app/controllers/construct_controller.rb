class ConstructController < BasicInstrumentController
  def create
    #TODO: Security issue
    @object = collection.create_with_position(params)
    if @object
      render :show, status: :created
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end
end