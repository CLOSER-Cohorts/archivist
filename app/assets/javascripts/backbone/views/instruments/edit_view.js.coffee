Archivist.Views.Instruments ||= {}

class Archivist.Views.Instruments.EditView extends Backbone.View
  template: JST["backbone/templates/instruments/edit"]

  events:
    "submit #edit-instrument": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (instrument) =>
        @model = instrument
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
