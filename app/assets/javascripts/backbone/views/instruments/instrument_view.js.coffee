Archivist.Views.Instruments ||= {}

class Archivist.Views.Instruments.InstrumentView extends Backbone.View
  template: JST["backbone/templates/instruments/instrument"]

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
