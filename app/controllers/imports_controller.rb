class ImportsController < ApplicationController
  def index
    @imports = Import.where(import_type: 'ImportJob::Instrument').order('created_at DESC')
  end

  def show
    @import = Import.find(params[:id])
  end
end
