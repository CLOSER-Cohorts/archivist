# A minimal controller that allows the loading of a single
# cluster at a time
#
# Clusters can not be edited or deleted as they are generated
# from other mapping and linking data
class ClustersController < ApplicationController
  # Loads a single cluster
  #
  # In order to load a cluster, a constituent member's class
  # and ID must be provided. Currently there is no way to load
  # a Cluster from its own id.
  #
  # Example:
  #   GET /clusters/:class/:id
  def show
    @object = params[:class].classify.constantize.find params[:id]
    @strand = @object.strand
    @cluster = @strand.cluster
  end
end