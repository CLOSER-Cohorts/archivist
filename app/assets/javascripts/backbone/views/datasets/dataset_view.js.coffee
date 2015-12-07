Archivist.Views.Datasets ||= {}

class Archivist.Views.Datasets.DatasetView extends Backbone.View
  template: JST["backbone/templates/datasets/dataset"]

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
