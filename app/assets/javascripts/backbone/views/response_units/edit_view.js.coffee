Archivist.Views.ResponseUnits ||= {}

class Archivist.Views.ResponseUnits.EditView extends Backbone.View
  template: JST["backbone/templates/response_units/edit"]

  events:
    "submit #edit-response_unit": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (response_unit) =>
        @model = response_unit
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
