Archivist.Views.Codes ||= {}

class Archivist.Views.Codes.EditView extends Backbone.View
  template: JST["backbone/templates/codes/edit"]

  events:
    "submit #edit-code": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (code) =>
        @model = code
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
