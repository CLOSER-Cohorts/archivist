Archivist.Views.Codes ||= {}

class Archivist.Views.Codes.NewView extends Backbone.View
  template: JST["backbone/templates/codes/new"]

  events:
    "submit #new-code": "save"

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
      success: (code) =>
        @model = code
        window.location.hash = "/#{@model.id}"

      error: (code, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
