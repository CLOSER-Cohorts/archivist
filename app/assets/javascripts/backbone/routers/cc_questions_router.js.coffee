class Archivist.Routers.CcQuestionsRouter extends Backbone.Router
  initialize: (options) ->
    @ccQuestions = new Archivist.Collections.CcQuestionsCollection()
    @ccQuestions.reset options.ccQuestions

  routes:
    "new"      : "newCcQuestion"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCcQuestion: ->
    @view = new Archivist.Views.CcQuestions.NewView(collection: @cc_questions)
    $("#cc_questions").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CcQuestions.IndexView(collection: @cc_questions)
    $("#cc_questions").html(@view.render().el)

  show: (id) ->
    cc_question = @cc_questions.get(id)

    @view = new Archivist.Views.CcQuestions.ShowView(model: cc_question)
    $("#cc_questions").html(@view.render().el)

  edit: (id) ->
    cc_question = @cc_questions.get(id)

    @view = new Archivist.Views.CcQuestions.EditView(model: cc_question)
    $("#cc_questions").html(@view.render().el)
