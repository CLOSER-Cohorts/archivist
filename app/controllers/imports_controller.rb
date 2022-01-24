# frozen_string_literal: true

class ImportsController < ApplicationController
  def index
    @imports = Import.where(import_type: 'ImportJob::Instrument').order('imports.created_at DESC')
    @documents = Document.all.select(:id, :filename)
  end

  def show
    @import = Import.find(params[:id])
  end
end
