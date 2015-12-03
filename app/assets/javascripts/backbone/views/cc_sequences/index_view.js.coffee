Archivist.Views.CcSequences ||= {}

class Archivist.Views.CcSequences.IndexView extends Backbone.View
  template: JST["backbone/templates/cc_sequences/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (ccSequence) =>
    view = new Archivist.Views.CcSequences.CcSequenceView({model : ccSequence})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(ccSequences: @collection.toJSON() ))
    @addAll()

    return this
