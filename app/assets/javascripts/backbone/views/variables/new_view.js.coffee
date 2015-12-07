Archivist.Views.Variables ||= {}

class Archivist.Views.Variables.NewView extends Backbone.View
  template: JST["backbone/templates/variables/new"]

  events:
    "submit #new-variable": "save"

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
      success: (variable) =>
        @model = variable
        window.location.hash = "/#{@model.id}"

      error: (variable, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
