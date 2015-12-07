Archivist.Views.Variables ||= {}

class Archivist.Views.Variables.VariableView extends Backbone.View
  template: JST["backbone/templates/variables/variable"]

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
