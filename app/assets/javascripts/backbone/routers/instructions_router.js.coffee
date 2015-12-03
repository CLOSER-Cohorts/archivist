class Archivist.Routers.InstructionsRouter extends Backbone.Router
  initialize: (options) ->
    @instructions = new Archivist.Collections.InstructionsCollection()
    @instructions.reset options.instructions

  routes:
    "new"      : "newInstruction"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newInstruction: ->
    @view = new Archivist.Views.Instructions.NewView(collection: @instructions)
    $("#instructions").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Instructions.IndexView(collection: @instructions)
    $("#instructions").html(@view.render().el)

  show: (id) ->
    instruction = @instructions.get(id)

    @view = new Archivist.Views.Instructions.ShowView(model: instruction)
    $("#instructions").html(@view.render().el)

  edit: (id) ->
    instruction = @instructions.get(id)

    @view = new Archivist.Views.Instructions.EditView(model: instruction)
    $("#instructions").html(@view.render().el)
