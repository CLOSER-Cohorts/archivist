Archivist.Views.ResponseDomainDatetimes ||= {}

class Archivist.Views.ResponseDomainDatetimes.EditView extends Backbone.View
  template: JST["backbone/templates/response_domain_datetimes/edit"]

  events:
    "submit #edit-response_domain_datetime": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (response_domain_datetime) =>
        @model = response_domain_datetime
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
