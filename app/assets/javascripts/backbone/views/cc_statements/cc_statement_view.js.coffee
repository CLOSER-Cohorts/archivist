Archivist.Views.CcStatements ||= {}

class Archivist.Views.CcStatements.CcStatementView extends Backbone.View
  template: JST["backbone/templates/cc_statements/cc_statement"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
