Archivist.Views.CcConditions ||= {}

class Archivist.Views.CcConditions.EditView extends Backbone.View
  template: JST["backbone/templates/cc_conditions/edit"]

  events:
    "submit #edit-cc_condition": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (cc_condition) =>
        @model = cc_condition
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
