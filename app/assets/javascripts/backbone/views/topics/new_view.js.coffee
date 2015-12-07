Archivist.Views.Topics ||= {}

class Archivist.Views.Topics.NewView extends Backbone.View
  template: JST["backbone/templates/topics/new"]

  events:
    "submit #new-topic": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (topic) =>
        @model = topic
        window.location.hash = "/#{@model.id}"

      error: (topic, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
