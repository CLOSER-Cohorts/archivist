Archivist.Views.QuestionGrids ||= {}

class Archivist.Views.QuestionGrids.IndexView extends Backbone.View
  template: JST["backbone/templates/question_grids/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (questionGrid) =>
    view = new Archivist.Views.QuestionGrids.QuestionGridView({model : questionGrid})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(questionGrids: @collection.toJSON() ))
    @addAll()

    return this
