Archivist.Views.ResponseUnits ||= {}

class Archivist.Views.ResponseUnits.ResponseUnitView extends Backbone.View
  template: JST["backbone/templates/response_units/response_unit"]

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
