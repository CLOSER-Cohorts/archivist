Archivist.Views.Datasets ||= {}

class Archivist.Views.Datasets.NewView extends Backbone.View
  template: JST["backbone/templates/datasets/new"]

  events:
    "submit #new-dataset": "save"

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
      success: (dataset) =>
        @model = dataset
        window.location.hash = "/#{@model.id}"

      error: (dataset, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
