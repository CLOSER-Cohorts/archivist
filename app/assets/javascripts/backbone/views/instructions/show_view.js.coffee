Archivist.Views.Instructions ||= {}

class Archivist.Views.Instructions.ShowView extends Backbone.View
  template: JST["backbone/templates/instructions/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
