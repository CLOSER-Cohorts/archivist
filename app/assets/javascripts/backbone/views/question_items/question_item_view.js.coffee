Archivist.Views.QuestionItems ||= {}

class Archivist.Views.QuestionItems.QuestionItemView extends Backbone.View
  template: JST["backbone/templates/question_items/question_item"]

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
