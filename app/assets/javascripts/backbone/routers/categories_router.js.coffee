class Archivist.Routers.CategoriesRouter extends Backbone.Router
  initialize: (options) ->
    @categories = new Archivist.Collections.CategoriesCollection()
    @categories.reset options.categories

  routes:
    "new"      : "newCategory"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCategory: ->
    @view = new Archivist.Views.Categories.NewView(collection: @categories)
    $("#categories").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Categories.IndexView(collection: @categories)
    $("#categories").html(@view.render().el)

  show: (id) ->
    category = @categories.get(id)

    @view = new Archivist.Views.Categories.ShowView(model: category)
    $("#categories").html(@view.render().el)

  edit: (id) ->
    category = @categories.get(id)

    @view = new Archivist.Views.Categories.EditView(model: category)
    $("#categories").html(@view.render().el)
