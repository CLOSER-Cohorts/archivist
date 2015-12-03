Archivist.Views.Codes ||= {}

class Archivist.Views.Codes.CodeView extends Backbone.View
  template: JST["backbone/templates/codes/code"]

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
