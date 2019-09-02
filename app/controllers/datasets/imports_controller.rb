class Datasets::ImportsController < ApplicationController
  def index
    dataset = Dataset.find(params[:dataset_id])
    @imports = dataset.imports.order(created_at: 'DESC')
  end

  def show
    dataset = Dataset.find(params[:dataset_id])
    @import = dataset.imports.find(params[:id])
  end
end
