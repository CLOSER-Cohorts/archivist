Archivist.Views.ResponseDomainTexts ||= {}

class Archivist.Views.ResponseDomainTexts.EditView extends Backbone.View
  template: JST["backbone/templates/response_domain_texts/edit"]

  events:
    "submit #edit-response_domain_text": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (response_domain_text) =>
        @model = response_domain_text
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
