Archivist.Views.CcLoops ||= {}

class Archivist.Views.CcLoops.EditView extends Backbone.View
  template: JST["backbone/templates/cc_loops/edit"]

  events:
    "submit #edit-cc_loop": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (cc_loop) =>
        @model = cc_loop
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
