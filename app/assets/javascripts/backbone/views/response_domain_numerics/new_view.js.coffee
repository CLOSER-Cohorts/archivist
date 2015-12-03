Archivist.Views.ResponseDomainNumerics ||= {}

class Archivist.Views.ResponseDomainNumerics.NewView extends Backbone.View
  template: JST["backbone/templates/response_domain_numerics/new"]

  events:
    "submit #new-response_domain_numeric": "save"

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
      success: (response_domain_numeric) =>
        @model = response_domain_numeric
        window.location.hash = "/#{@model.id}"

      error: (response_domain_numeric, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
