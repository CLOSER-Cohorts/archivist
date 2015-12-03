class Archivist.Routers.QuestionGridsRouter extends Backbone.Router
  initialize: (options) ->
    @questionGrids = new Archivist.Collections.QuestionGridsCollection()
    @questionGrids.reset options.questionGrids

  routes:
    "new"      : "newQuestionGrid"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newQuestionGrid: ->
    @view = new Archivist.Views.QuestionGrids.NewView(collection: @question_grids)
    $("#question_grids").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.QuestionGrids.IndexView(collection: @question_grids)
    $("#question_grids").html(@view.render().el)

  show: (id) ->
    question_grid = @question_grids.get(id)

    @view = new Archivist.Views.QuestionGrids.ShowView(model: question_grid)
    $("#question_grids").html(@view.render().el)

  edit: (id) ->
    question_grid = @question_grids.get(id)

    @view = new Archivist.Views.QuestionGrids.EditView(model: question_grid)
    $("#question_grids").html(@view.render().el)
