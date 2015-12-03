Archivist.Views.CodeLists ||= {}

class Archivist.Views.CodeLists.CodeListView extends Backbone.View
  template: JST["backbone/templates/code_lists/code_list"]

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
