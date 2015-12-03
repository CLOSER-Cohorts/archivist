Archivist.Views.ResponseDomainTexts ||= {}

class Archivist.Views.ResponseDomainTexts.ResponseDomainTextView extends Backbone.View
  template: JST["backbone/templates/response_domain_texts/response_domain_text"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
