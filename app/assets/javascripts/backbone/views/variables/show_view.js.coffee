Archivist.Views.Variables ||= {}

class Archivist.Views.Variables.ShowView extends Backbone.View
  template: JST["backbone/templates/variables/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
