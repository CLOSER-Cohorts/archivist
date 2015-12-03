Archivist.Views.CcQuestions ||= {}

class Archivist.Views.CcQuestions.ShowView extends Backbone.View
  template: JST["backbone/templates/cc_questions/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
