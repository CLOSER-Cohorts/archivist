Archivist.Views.ResponseDomainCodes ||= {}

class Archivist.Views.ResponseDomainCodes.EditView extends Backbone.View
  template: JST["backbone/templates/response_domain_codes/edit"]

  events:
    "submit #edit-response_domain_code": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (response_domain_code) =>
        @model = response_domain_code
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
