Archivist.Views.QuestionGrids ||= {}

class Archivist.Views.QuestionGrids.ShowView extends Backbone.View
  template: JST["backbone/templates/question_grids/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
