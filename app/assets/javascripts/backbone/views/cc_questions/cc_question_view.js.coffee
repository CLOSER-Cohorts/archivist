Archivist.Views.CcQuestions ||= {}

class Archivist.Views.CcQuestions.CcQuestionView extends Backbone.View
  template: JST["backbone/templates/cc_questions/cc_question"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
