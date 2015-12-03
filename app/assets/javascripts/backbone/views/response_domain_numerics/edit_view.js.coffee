Archivist.Views.ResponseDomainNumerics ||= {}

class Archivist.Views.ResponseDomainNumerics.EditView extends Backbone.View
  template: JST["backbone/templates/response_domain_numerics/edit"]

  events:
    "submit #edit-response_domain_numeric": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (response_domain_numeric) =>
        @model = response_domain_numeric
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
