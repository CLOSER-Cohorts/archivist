Archivist.Views.Topics ||= {}

class Archivist.Views.Topics.ShowView extends Backbone.View
  template: JST["backbone/templates/topics/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
