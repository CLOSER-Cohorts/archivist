class Archivist.Routers.CodeListsRouter extends Backbone.Router
  initialize: (options) ->
    @codeLists = new Archivist.Collections.CodeListsCollection()
    @codeLists.reset options.codeLists

  routes:
    "new"      : "newCodeList"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCodeList: ->
    @view = new Archivist.Views.CodeLists.NewView(collection: @code_lists)
    $("#code_lists").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CodeLists.IndexView(collection: @code_lists)
    $("#code_lists").html(@view.render().el)

  show: (id) ->
    code_list = @code_lists.get(id)

    @view = new Archivist.Views.CodeLists.ShowView(model: code_list)
    $("#code_lists").html(@view.render().el)

  edit: (id) ->
    code_list = @code_lists.get(id)

    @view = new Archivist.Views.CodeLists.EditView(model: code_list)
    $("#code_lists").html(@view.render().el)
