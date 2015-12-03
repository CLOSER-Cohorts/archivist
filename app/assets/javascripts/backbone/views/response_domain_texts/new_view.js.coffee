Archivist.Views.ResponseDomainTexts ||= {}

class Archivist.Views.ResponseDomainTexts.NewView extends Backbone.View
  template: JST["backbone/templates/response_domain_texts/new"]

  events:
    "submit #new-response_domain_text": "save"

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
      success: (response_domain_text) =>
        @model = response_domain_text
        window.location.hash = "/#{@model.id}"

      error: (response_domain_text, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
