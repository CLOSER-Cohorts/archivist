Archivist.Views.ResponseDomainCodes ||= {}

class Archivist.Views.ResponseDomainCodes.ResponseDomainCodeView extends Backbone.View
  template: JST["backbone/templates/response_domain_codes/response_domain_code"]

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
