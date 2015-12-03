Archivist.Views.QuestionGrids ||= {}

class Archivist.Views.QuestionGrids.QuestionGridView extends Backbone.View
  template: JST["backbone/templates/question_grids/question_grid"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
