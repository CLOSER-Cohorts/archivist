class Archivist.Routers.CcConditionsRouter extends Backbone.Router
  initialize: (options) ->
    @ccConditions = new Archivist.Collections.CcConditionsCollection()
    @ccConditions.reset options.ccConditions

  routes:
    "new"      : "newCcCondition"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCcCondition: ->
    @view = new Archivist.Views.CcConditions.NewView(collection: @cc_conditions)
    $("#cc_conditions").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CcConditions.IndexView(collection: @cc_conditions)
    $("#cc_conditions").html(@view.render().el)

  show: (id) ->
    cc_condition = @cc_conditions.get(id)

    @view = new Archivist.Views.CcConditions.ShowView(model: cc_condition)
    $("#cc_conditions").html(@view.render().el)

  edit: (id) ->
    cc_condition = @cc_conditions.get(id)

    @view = new Archivist.Views.CcConditions.EditView(model: cc_condition)
    $("#cc_conditions").html(@view.render().el)
