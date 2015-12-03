Archivist.Views.CcStatements ||= {}

class Archivist.Views.CcStatements.ShowView extends Backbone.View
  template: JST["backbone/templates/cc_statements/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
