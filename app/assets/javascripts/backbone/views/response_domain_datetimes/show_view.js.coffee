Archivist.Views.ResponseDomainDatetimes ||= {}

class Archivist.Views.ResponseDomainDatetimes.ShowView extends Backbone.View
  template: JST["backbone/templates/response_domain_datetimes/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
