Archivist.Views.Instruments ||= {}

class Archivist.Views.Instruments.NewView extends Backbone.View
  template: JST["backbone/templates/instruments/new"]

  events:
    "submit #new-instrument": "save"

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
      success: (instrument) =>
        @model = instrument
        window.location.hash = "/#{@model.id}"

      error: (instrument, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
