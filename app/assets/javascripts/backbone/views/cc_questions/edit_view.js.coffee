Archivist.Views.CcQuestions ||= {}

class Archivist.Views.CcQuestions.EditView extends Backbone.View
  template: JST["backbone/templates/cc_questions/edit"]

  events:
    "submit #edit-cc_question": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (cc_question) =>
        @model = cc_question
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
