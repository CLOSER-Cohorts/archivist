Archivist.Views.CcSequences ||= {}

class Archivist.Views.CcSequences.NewView extends Backbone.View
  template: JST["backbone/templates/cc_sequences/new"]

  events:
    "submit #new-cc_sequence": "save"

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
      success: (cc_sequence) =>
        @model = cc_sequence
        window.location.hash = "/#{@model.id}"

      error: (cc_sequence, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
