Archivist.Views.Categories ||= {}

class Archivist.Views.Categories.IndexView extends Backbone.View
  template: JST["backbone/templates/categories/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (category) =>
    view = new Archivist.Views.Categories.CategoryView({model : category})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(categories: @collection.toJSON() ))
    @addAll()

    return this
