Archivist.Views.Instructions ||= {}

class Archivist.Views.Instructions.EditView extends Backbone.View
  template: JST["backbone/templates/instructions/edit"]

  events:
    "submit #edit-instruction": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (instruction) =>
        @model = instruction
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
