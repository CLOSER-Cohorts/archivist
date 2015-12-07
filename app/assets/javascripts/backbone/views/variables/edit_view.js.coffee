Archivist.Views.Variables ||= {}

class Archivist.Views.Variables.EditView extends Backbone.View
  template: JST["backbone/templates/variables/edit"]

  events:
    "submit #edit-variable": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (variable) =>
        @model = variable
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
