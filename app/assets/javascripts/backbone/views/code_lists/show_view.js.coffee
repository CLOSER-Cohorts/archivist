Archivist.Views.CodeLists ||= {}

class Archivist.Views.CodeLists.ShowView extends Backbone.View
  template: JST["backbone/templates/code_lists/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
