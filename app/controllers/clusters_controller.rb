class ClustersController < ApplicationController
  def show
    @object = params[:class].classify.constantize.find params[:id]
    @strand = @object.strand
    @cluster = @strand.cluster
  end
end