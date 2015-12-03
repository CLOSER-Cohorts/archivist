Archivist.Views.CcLoops ||= {}

class Archivist.Views.CcLoops.IndexView extends Backbone.View
  template: JST["backbone/templates/cc_loops/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (ccLoop) =>
    view = new Archivist.Views.CcLoops.CcLoopView({model : ccLoop})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(ccLoops: @collection.toJSON() ))
    @addAll()

    return this
