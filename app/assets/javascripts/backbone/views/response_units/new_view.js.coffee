Archivist.Views.ResponseUnits ||= {}

class Archivist.Views.ResponseUnits.NewView extends Backbone.View
  template: JST["backbone/templates/response_units/new"]

  events:
    "submit #new-response_unit": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (response_unit) =>
        @model = response_unit
        window.location.hash = "/#{@model.id}"

      error: (response_unit, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
