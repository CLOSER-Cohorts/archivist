Archivist.Views.CcLoops ||= {}

class Archivist.Views.CcLoops.CcLoopView extends Backbone.View
  template: JST["backbone/templates/cc_loops/cc_loop"]

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
