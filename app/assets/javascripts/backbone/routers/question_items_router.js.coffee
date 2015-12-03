class Archivist.Routers.QuestionItemsRouter extends Backbone.Router
  initialize: (options) ->
    @questionItems = new Archivist.Collections.QuestionItemsCollection()
    @questionItems.reset options.questionItems

  routes:
    "new"      : "newQuestionItem"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newQuestionItem: ->
    @view = new Archivist.Views.QuestionItems.NewView(collection: @question_items)
    $("#question_items").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.QuestionItems.IndexView(collection: @question_items)
    $("#question_items").html(@view.render().el)

  show: (id) ->
    question_item = @question_items.get(id)

    @view = new Archivist.Views.QuestionItems.ShowView(model: question_item)
    $("#question_items").html(@view.render().el)

  edit: (id) ->
    question_item = @question_items.get(id)

    @view = new Archivist.Views.QuestionItems.EditView(model: question_item)
    $("#question_items").html(@view.render().el)
