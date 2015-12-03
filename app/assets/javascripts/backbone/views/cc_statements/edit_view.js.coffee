Archivist.Views.CcStatements ||= {}

class Archivist.Views.CcStatements.EditView extends Backbone.View
  template: JST["backbone/templates/cc_statements/edit"]

  events:
    "submit #edit-cc_statement": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (cc_statement) =>
        @model = cc_statement
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
