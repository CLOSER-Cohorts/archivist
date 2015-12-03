Archivist.Views.CcSequences ||= {}

class Archivist.Views.CcSequences.ShowView extends Backbone.View
  template: JST["backbone/templates/cc_sequences/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
