Archivist.Views.Instructions ||= {}

class Archivist.Views.Instructions.InstructionView extends Backbone.View
  template: JST["backbone/templates/instructions/instruction"]

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
