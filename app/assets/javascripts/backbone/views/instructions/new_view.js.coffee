Archivist.Views.Instructions ||= {}

class Archivist.Views.Instructions.NewView extends Backbone.View
  template: JST["backbone/templates/instructions/new"]

  events:
    "submit #new-instruction": "save"

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
      success: (instruction) =>
        @model = instruction
        window.location.hash = "/#{@model.id}"

      error: (instruction, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
