class Archivist.Routers.CcStatementsRouter extends Backbone.Router
  initialize: (options) ->
    @ccStatements = new Archivist.Collections.CcStatementsCollection()
    @ccStatements.reset options.ccStatements

  routes:
    "new"      : "newCcStatement"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCcStatement: ->
    @view = new Archivist.Views.CcStatements.NewView(collection: @cc_statements)
    $("#cc_statements").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CcStatements.IndexView(collection: @cc_statements)
    $("#cc_statements").html(@view.render().el)

  show: (id) ->
    cc_statement = @cc_statements.get(id)

    @view = new Archivist.Views.CcStatements.ShowView(model: cc_statement)
    $("#cc_statements").html(@view.render().el)

  edit: (id) ->
    cc_statement = @cc_statements.get(id)

    @view = new Archivist.Views.CcStatements.EditView(model: cc_statement)
    $("#cc_statements").html(@view.render().el)
