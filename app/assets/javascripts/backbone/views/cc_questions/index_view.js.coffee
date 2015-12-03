Archivist.Views.CcQuestions ||= {}

class Archivist.Views.CcQuestions.IndexView extends Backbone.View
  template: JST["backbone/templates/cc_questions/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (ccQuestion) =>
    view = new Archivist.Views.CcQuestions.CcQuestionView({model : ccQuestion})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(ccQuestions: @collection.toJSON() ))
    @addAll()

    return this
