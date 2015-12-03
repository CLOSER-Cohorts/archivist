class Archivist.Routers.ResponseUnitsRouter extends Backbone.Router
  initialize: (options) ->
    @responseUnits = new Archivist.Collections.ResponseUnitsCollection()
    @responseUnits.reset options.responseUnits

  routes:
    "new"      : "newResponseUnit"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newResponseUnit: ->
    @view = new Archivist.Views.ResponseUnits.NewView(collection: @response_units)
    $("#response_units").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.ResponseUnits.IndexView(collection: @response_units)
    $("#response_units").html(@view.render().el)

  show: (id) ->
    response_unit = @response_units.get(id)

    @view = new Archivist.Views.ResponseUnits.ShowView(model: response_unit)
    $("#response_units").html(@view.render().el)

  edit: (id) ->
    response_unit = @response_units.get(id)

    @view = new Archivist.Views.ResponseUnits.EditView(model: response_unit)
    $("#response_units").html(@view.render().el)
