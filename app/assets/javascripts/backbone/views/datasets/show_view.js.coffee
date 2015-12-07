Archivist.Views.Datasets ||= {}

class Archivist.Views.Datasets.ShowView extends Backbone.View
  template: JST["backbone/templates/datasets/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
