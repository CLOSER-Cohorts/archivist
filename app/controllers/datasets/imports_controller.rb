# frozen_string_literal: true

class Datasets::ImportsController < ApplicationController
  def index
    dataset = Dataset.find(params[:dataset_id])
    @imports = dataset.imports.order(created_at: 'DESC')
  end

  def show
    dataset = Dataset.find(params[:dataset_id])
    @import = dataset.imports.find(params[:id])
  end

  def document
    dataset = Dataset.find(params[:dataset_id])
    @import = dataset.imports.find(params[:id])
    
    @document = @import.document

    file_name = @document.filename
    file_contents = @document.file_contents
  
    send_data file_contents, filename: file_name, type: "text/plain", disposition: "attachment"
  end  
end
