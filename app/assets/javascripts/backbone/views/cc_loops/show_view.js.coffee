Archivist.Views.CcLoops ||= {}

class Archivist.Views.CcLoops.ShowView extends Backbone.View
  template: JST["backbone/templates/cc_loops/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
