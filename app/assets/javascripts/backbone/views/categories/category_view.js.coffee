Archivist.Views.Categories ||= {}

class Archivist.Views.Categories.CategoryView extends Backbone.View
  template: JST["backbone/templates/categories/category"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
