Archivist.Views.QuestionGrids ||= {}

class Archivist.Views.QuestionGrids.NewView extends Backbone.View
  template: JST["backbone/templates/question_grids/new"]

  events:
    "submit #new-question_grid": "save"

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
      success: (question_grid) =>
        @model = question_grid
        window.location.hash = "/#{@model.id}"

      error: (question_grid, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
