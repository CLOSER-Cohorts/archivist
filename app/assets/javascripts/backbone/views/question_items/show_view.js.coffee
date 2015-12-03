Archivist.Views.QuestionItems ||= {}

class Archivist.Views.QuestionItems.ShowView extends Backbone.View
  template: JST["backbone/templates/question_items/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
