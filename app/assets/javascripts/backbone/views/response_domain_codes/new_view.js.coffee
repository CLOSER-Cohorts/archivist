Archivist.Views.ResponseDomainCodes ||= {}

class Archivist.Views.ResponseDomainCodes.NewView extends Backbone.View
  template: JST["backbone/templates/response_domain_codes/new"]

  events:
    "submit #new-response_domain_code": "save"

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
      success: (response_domain_code) =>
        @model = response_domain_code
        window.location.hash = "/#{@model.id}"

      error: (response_domain_code, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
