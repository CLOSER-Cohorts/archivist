Archivist.Views.CcStatements ||= {}

class Archivist.Views.CcStatements.NewView extends Backbone.View
  template: JST["backbone/templates/cc_statements/new"]

  events:
    "submit #new-cc_statement": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (cc_statement) =>
        @model = cc_statement
        window.location.hash = "/#{@model.id}"

      error: (cc_statement, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
