Archivist.Views.ResponseUnits ||= {}

class Archivist.Views.ResponseUnits.ShowView extends Backbone.View
  template: JST["backbone/templates/response_units/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
