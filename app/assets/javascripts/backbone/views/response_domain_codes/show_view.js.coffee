Archivist.Views.ResponseDomainCodes ||= {}

class Archivist.Views.ResponseDomainCodes.ShowView extends Backbone.View
  template: JST["backbone/templates/response_domain_codes/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
