Archivist.Views.CcSequences ||= {}

class Archivist.Views.CcSequences.CcSequenceView extends Backbone.View
  template: JST["backbone/templates/cc_sequences/cc_sequence"]

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
