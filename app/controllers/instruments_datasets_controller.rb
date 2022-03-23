# frozen_string_literal: true

class InstrumentsDatasetsController < BasicController
  def create
    @instrument = Instrument.find(params[:instrument_id])
    InstrumentsDatasets.create!(instrument_id: params[:instrument_id], dataset_id: params[:dataset_id])
    @instrument.touch
    render json: Instruments::Serializer.new(@instrument).call()
  end

  def destroy
    @instrument = Instrument.find(params[:instrument_id])
    InstrumentsDatasets.where(instrument_id: params[:instrument_id], dataset_id: params[:dataset_id]).first.try(:destroy)
    @instrument.touch
    render json: Instruments::Serializer.new(@instrument).call()
  end
end