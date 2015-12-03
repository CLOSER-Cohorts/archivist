Archivist.Views.CcConditions ||= {}

class Archivist.Views.CcConditions.NewView extends Backbone.View
  template: JST["backbone/templates/cc_conditions/new"]

  events:
    "submit #new-cc_condition": "save"

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
      success: (cc_condition) =>
        @model = cc_condition
        window.location.hash = "/#{@model.id}"

      error: (cc_condition, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
