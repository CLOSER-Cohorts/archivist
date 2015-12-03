Archivist.Views.CcLoops ||= {}

class Archivist.Views.CcLoops.NewView extends Backbone.View
  template: JST["backbone/templates/cc_loops/new"]

  events:
    "submit #new-cc_loop": "save"

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
      success: (cc_loop) =>
        @model = cc_loop
        window.location.hash = "/#{@model.id}"

      error: (cc_loop, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
