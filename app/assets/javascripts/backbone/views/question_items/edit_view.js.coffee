Archivist.Views.QuestionItems ||= {}

class Archivist.Views.QuestionItems.EditView extends Backbone.View
  template: JST["backbone/templates/question_items/edit"]

  events:
    "submit #edit-question_item": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (question_item) =>
        @model = question_item
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
