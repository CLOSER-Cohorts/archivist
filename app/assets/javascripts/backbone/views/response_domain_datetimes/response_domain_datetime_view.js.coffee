Archivist.Views.ResponseDomainDatetimes ||= {}

class Archivist.Views.ResponseDomainDatetimes.ResponseDomainDatetimeView extends Backbone.View
  template: JST["backbone/templates/response_domain_datetimes/response_domain_datetime"]

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
