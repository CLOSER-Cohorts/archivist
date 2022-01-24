# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :set_documents

  def index
    @imports = Import.where(import_type: 'ImportJob::Instrument').order('imports.created_at DESC')
  end

  def show
    @import = Import.find(params[:id])
  end

  private

  def set_documents
    @documents = Document.all.select(:id, :filename)
  end
end
