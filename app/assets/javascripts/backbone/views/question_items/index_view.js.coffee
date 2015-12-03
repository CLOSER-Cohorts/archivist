Archivist.Views.QuestionItems ||= {}

class Archivist.Views.QuestionItems.IndexView extends Backbone.View
  template: JST["backbone/templates/question_items/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (questionItem) =>
    view = new Archivist.Views.QuestionItems.QuestionItemView({model : questionItem})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(questionItems: @collection.toJSON() ))
    @addAll()

    return this
