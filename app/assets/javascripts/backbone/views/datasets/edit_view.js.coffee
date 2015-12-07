Archivist.Views.Datasets ||= {}

class Archivist.Views.Datasets.EditView extends Backbone.View
  template: JST["backbone/templates/datasets/edit"]

  events:
    "submit #edit-dataset": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (dataset) =>
        @model = dataset
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
