Archivist.Views.QuestionGrids ||= {}

class Archivist.Views.QuestionGrids.EditView extends Backbone.View
  template: JST["backbone/templates/question_grids/edit"]

  events:
    "submit #edit-question_grid": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (question_grid) =>
        @model = question_grid
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
