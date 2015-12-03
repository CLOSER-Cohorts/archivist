Archivist.Views.ResponseDomainNumerics ||= {}

class Archivist.Views.ResponseDomainNumerics.ShowView extends Backbone.View
  template: JST["backbone/templates/response_domain_numerics/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
