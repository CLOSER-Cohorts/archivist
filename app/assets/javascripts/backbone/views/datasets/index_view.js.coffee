Archivist.Views.Datasets ||= {}

class Archivist.Views.Datasets.IndexView extends Backbone.View
  template: JST["backbone/templates/datasets/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (dataset) =>
    view = new Archivist.Views.Datasets.DatasetView({model : dataset})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(datasets: @collection.toJSON() ))
    @addAll()

    return this
