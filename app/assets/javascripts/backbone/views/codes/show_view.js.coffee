Archivist.Views.Codes ||= {}

class Archivist.Views.Codes.ShowView extends Backbone.View
  template: JST["backbone/templates/codes/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
