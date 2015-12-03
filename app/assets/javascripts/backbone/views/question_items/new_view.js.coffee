Archivist.Views.QuestionItems ||= {}

class Archivist.Views.QuestionItems.NewView extends Backbone.View
  template: JST["backbone/templates/question_items/new"]

  events:
    "submit #new-question_item": "save"

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
      success: (question_item) =>
        @model = question_item
        window.location.hash = "/#{@model.id}"

      error: (question_item, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
