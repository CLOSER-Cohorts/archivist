class Archivist.Routers.CcLoopsRouter extends Backbone.Router
  initialize: (options) ->
    @ccLoops = new Archivist.Collections.CcLoopsCollection()
    @ccLoops.reset options.ccLoops

  routes:
    "new"      : "newCcLoop"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCcLoop: ->
    @view = new Archivist.Views.CcLoops.NewView(collection: @cc_loops)
    $("#cc_loops").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CcLoops.IndexView(collection: @cc_loops)
    $("#cc_loops").html(@view.render().el)

  show: (id) ->
    cc_loop = @cc_loops.get(id)

    @view = new Archivist.Views.CcLoops.ShowView(model: cc_loop)
    $("#cc_loops").html(@view.render().el)

  edit: (id) ->
    cc_loop = @cc_loops.get(id)

    @view = new Archivist.Views.CcLoops.EditView(model: cc_loop)
    $("#cc_loops").html(@view.render().el)
