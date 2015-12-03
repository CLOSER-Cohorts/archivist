Archivist.Views.CcSequences ||= {}

class Archivist.Views.CcSequences.EditView extends Backbone.View
  template: JST["backbone/templates/cc_sequences/edit"]

  events:
    "submit #edit-cc_sequence": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (cc_sequence) =>
        @model = cc_sequence
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
