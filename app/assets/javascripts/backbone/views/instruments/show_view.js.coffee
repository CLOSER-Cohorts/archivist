Archivist.Views.Instruments ||= {}

class Archivist.Views.Instruments.ShowView extends Backbone.View
  template: JST["backbone/templates/instruments/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
