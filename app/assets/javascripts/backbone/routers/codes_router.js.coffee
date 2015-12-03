class Archivist.Routers.CodesRouter extends Backbone.Router
  initialize: (options) ->
    @codes = new Archivist.Collections.CodesCollection()
    @codes.reset options.codes

  routes:
    "new"      : "newCode"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCode: ->
    @view = new Archivist.Views.Codes.NewView(collection: @codes)
    $("#codes").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Codes.IndexView(collection: @codes)
    $("#codes").html(@view.render().el)

  show: (id) ->
    code = @codes.get(id)

    @view = new Archivist.Views.Codes.ShowView(model: code)
    $("#codes").html(@view.render().el)

  edit: (id) ->
    code = @codes.get(id)

    @view = new Archivist.Views.Codes.EditView(model: code)
    $("#codes").html(@view.render().el)
