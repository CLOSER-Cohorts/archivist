class Archivist.Routers.DatasetsRouter extends Backbone.Router
  initialize: (options) ->
    @datasets = new Archivist.Collections.DatasetsCollection()
    @datasets.reset options.datasets

  routes:
    "new"      : "newDataset"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newDataset: ->
    @view = new Archivist.Views.Datasets.NewView(collection: @datasets)
    $("#datasets").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Datasets.IndexView(collection: @datasets)
    $("#datasets").html(@view.render().el)

  show: (id) ->
    dataset = @datasets.get(id)

    @view = new Archivist.Views.Datasets.ShowView(model: dataset)
    $("#datasets").html(@view.render().el)

  edit: (id) ->
    dataset = @datasets.get(id)

    @view = new Archivist.Views.Datasets.EditView(model: dataset)
    $("#datasets").html(@view.render().el)
