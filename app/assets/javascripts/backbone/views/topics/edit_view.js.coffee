Archivist.Views.Topics ||= {}

class Archivist.Views.Topics.EditView extends Backbone.View
  template: JST["backbone/templates/topics/edit"]

  events:
    "submit #edit-topic": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (topic) =>
        @model = topic
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
