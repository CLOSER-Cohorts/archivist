class Archivist.Routers.VariablesRouter extends Backbone.Router
  initialize: (options) ->
    @variables = new Archivist.Collections.VariablesCollection()
    @variables.reset options.variables

  routes:
    "new"      : "newVariable"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newVariable: ->
    @view = new Archivist.Views.Variables.NewView(collection: @variables)
    $("#variables").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Variables.IndexView(collection: @variables)
    $("#variables").html(@view.render().el)

  show: (id) ->
    variable = @variables.get(id)

    @view = new Archivist.Views.Variables.ShowView(model: variable)
    $("#variables").html(@view.render().el)

  edit: (id) ->
    variable = @variables.get(id)

    @view = new Archivist.Views.Variables.EditView(model: variable)
    $("#variables").html(@view.render().el)
