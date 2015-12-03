Archivist.Views.Instructions ||= {}

class Archivist.Views.Instructions.IndexView extends Backbone.View
  template: JST["backbone/templates/instructions/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (instruction) =>
    view = new Archivist.Views.Instructions.InstructionView({model : instruction})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(instructions: @collection.toJSON() ))
    @addAll()

    return this
