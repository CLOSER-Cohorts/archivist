Archivist.Views.Topics ||= {}

class Archivist.Views.Topics.TopicView extends Backbone.View
  template: JST["backbone/templates/topics/topic"]

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
